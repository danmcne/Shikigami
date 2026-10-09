class_name Sound
extends Node
## The game's sound, all synthesized (no recorded audio is shipped): a temple
## bell (kane) to open each round, a gong for a knockout, hits light and heavy,
## a giant's boom, the dry knock of a block, a tick for menus, and two looping
## tunes for a small ensemble on the hirajōshi scale: shamisen, shakuhachi,
## taiko and kotsuzumi, slow for the menus and driving for fights. Each sound
## is made the first time it is wanted.

const RATE := 22050
## D hirajōshi: D, E, F, A, B-flat.
const SCALE := [146.83, 164.81, 174.61, 220.0, 233.08]

var _players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _made: Dictionary = {}
var _tune := ""
var _last_played: Dictionary = {}
## Tunes take about a second to make, so they are made on a worker thread;
## the music starts when its tune is ready. {name: task id}
var _making: Dictionary = {}
var _mutex := Mutex.new()


func _ready() -> void:
	for k in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -9.0
	add_child(_music)
	# Effects are quick; make the bell now so the first round's is on time.
	stream("bell")
	prepare()


## Plays an effect by name (see _synth). The same effect asked for again
## within a few frames is heard once (a volley of bolts rolls one thunder);
## when every player is busy, the one furthest through its sound gives way, so
## a new sound is never dropped.
func play(name: String, volume_db := 0.0) -> void:
	if not Settings.sound_on():
		return
	var now := Time.get_ticks_msec()
	if now - _last_played.get(name, -1000) < 70:
		return
	_last_played[name] = now
	var chosen: AudioStreamPlayer = null
	var furthest := -1.0
	for p in _players:
		if not p.playing:
			chosen = p
			break
		var through := p.get_playback_position() / maxf(p.stream.get_length(), 0.001)
		if through > furthest:
			furthest = through
			chosen = p
	chosen.stream = stream(name)
	chosen.volume_db = volume_db
	chosen.play()


## Starts a tune (menu, fight), or "" for silence; no change if already playing.
func music(name: String) -> void:
	if not Settings.music_on():
		name = ""
	if name == _tune:
		return
	_tune = name
	_music.stop()
	if name == "":
		return
	_mutex.lock()
	var ready := _made.has(name)
	_mutex.unlock()
	if ready:
		_music.stream = _made[name]
		_music.play()
	elif not _making.has(name):
		_making[name] = WorkerThreadPool.add_task(_make_in_background.bind(name))


func _make_in_background(name: String) -> void:
	var w := _wav(_synth(name), true)
	_mutex.lock()
	_made[name] = w
	_mutex.unlock()


func _process(_delta: float) -> void:
	for name in _making.keys():
		if WorkerThreadPool.is_task_completed(_making[name]):
			WorkerThreadPool.wait_for_task_completion(_making[name])
			_making.erase(name)
			# Begin it if it is still the tune wanted.
			if name == _tune and not _music.playing:
				_music.stream = _made[name]
				_music.play()


func _exit_tree() -> void:
	for name in _making:
		WorkerThreadPool.wait_for_task_completion(_making[name])


func stream(name: String) -> AudioStreamWAV:
	_mutex.lock()
	var have := _made.has(name)
	_mutex.unlock()
	if not have:
		var w := _wav(_synth(name), name in ["menu", "fight"])
		_mutex.lock()
		_made[name] = w
		_mutex.unlock()
	return _made[name]


## Starts making the tunes in the background, ahead of need.
func prepare() -> void:
	for name in ["menu", "fight"]:
		if not _made.has(name) and not _making.has(name):
			_making[name] = WorkerThreadPool.add_task(_make_in_background.bind(name))


func _synth(name: String) -> PackedFloat32Array:
	match name:
		"bell":
			return _bell(196.0, 3.2, [1.0, 2.76, 5.40, 8.93], [1.0, 0.5, 0.28, 0.16], [2.6, 1.3, 0.6, 0.3])
		"gong":
			return _bell(98.0, 3.8, [1.0, 1.52, 2.31, 3.12], [1.0, 0.6, 0.4, 0.25], [3.0, 1.8, 1.0, 0.6])
		"hit":
			return _strike(0.14, 160.0, 0.05, 0.03)
		"hit_heavy":
			return _strike(0.3, 85.0, 0.14, 0.06)
		"giant_hit":
			# A giant's blow on a fighter: a deep boom, a crack, a lingering drum.
			var boom := _strike(0.9, 48.0, 0.35, 0.08)
			_add(boom, _taiko(0.8), 0)
			return _normalised(boom, 0.9)
		"giant_slam":
			# A giant's blow striking the ground: a heavy thud, booming, with a
			# soft tail of rumble.
			var slam := _silence(0.9)
			_add(slam, _strike(0.8, 60.0, 0.28, 0.04), 0)
			_add(slam, _taiko(1.0), 0)
			_add(slam, _body(0.5, [110.0, 165.0], 0.1, 0.35), 0)
			_add(slam, _rumble(0.8, 0.3, 0.15), 0)
			return _normalised(slam, 0.9)
		"giant_swing":
			# A great limb sweeping through the air: a rush of wind, rising.
			return _normalised(_whoosh(0.5, 280.0, 1100.0), 0.75)
		"thunder":
			# A lightning bolt: a sharp crack, then the long roll of thunder.
			var thunder := _silence(1.7)
			_add(thunder, _crunch(0.15, 0.02, 0.9), 0)
			_add(thunder, _body(0.4, [180.0, 260.0], 0.08, 0.4), 0)
			_add(thunder, _rumble(1.6, 0.6, 0.6), int(0.03 * RATE))
			return _normalised(thunder, 0.9)
		"block":
			var out := _tone(0.09, 880.0, 0.016, 0.6)
			_add(out, _tone(0.09, 1370.0, 0.01, 0.4), 0)
			return out
		"tick":
			return _tone(0.04, 1250.0, 0.01, 0.4)
		"menu":
			return _ensemble(false)
		"fight":
			return _ensemble(true)
	return PackedFloat32Array([0.0])


## A struck bell: inharmonic partials, each decaying at its own rate, the
## fundamental doubled with a hair's detune for its slow beating.
func _bell(f0: float, seconds: float, ratios: Array, amps: Array, decays: Array) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		var v := 0.0
		for k in ratios.size():
			v += amps[k] * exp(-t / decays[k]) * sin(TAU * f0 * ratios[k] * t)
		v += 0.35 * exp(-t / decays[0]) * sin(TAU * f0 * 1.004 * t)
		if t < 0.02:
			v += (randf() * 2.0 - 1.0) * (1.0 - t / 0.02) * 0.4
		out[i] = v * 0.32
	return out


## Silence of a given length, to mix a one-off sound into (mixing wraps what
## runs past the end, as a loop needs, so a one-off must start long enough).
func _silence(seconds: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(seconds * RATE))
	return out


## Damped resonances: the body of something struck, ringing briefly.
func _body(seconds: float, freqs: Array, decay: float, amp: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		var v := 0.0
		for k in freqs.size():
			v += sin(TAU * freqs[k] * t * (1.0 - 0.15 * t)) / (1.0 + k)
		out[i] = amp * exp(-t / decay) * v
	return out


## A crunch: noise in the middle of the hearing (roughly 500 Hz to 4 kHz).
func _crunch(seconds: float, decay: float, amp: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var slow := 0.0
	var fast := 0.0
	for i in n:
		var t := float(i) / RATE
		var x := randf() * 2.0 - 1.0
		fast = lerpf(fast, x, 0.6)
		slow = lerpf(slow, x, 0.13)
		out[i] = amp * exp(-t / decay) * (fast - slow) * 2.0
	return out


## A rumble: low noise around 100 to 400 Hz, dying away.
func _rumble(seconds: float, decay: float, amp: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var a := 0.0
	var b := 0.0
	for i in n:
		var t := float(i) / RATE
		var x := randf() * 2.0 - 1.0
		a = lerpf(a, x, 0.11)
		b = lerpf(b, x, 0.03)
		out[i] = amp * exp(-t / decay) * minf(t / 0.02, 1.0) * (a - b) * 4.0
	return out


## A whoosh: noise through a band that sweeps upward, swelling and fading.
func _whoosh(seconds: float, from_hz: float, to_hz: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var low := 0.0
	var high := 0.0
	for i in n:
		var u := float(i) / n
		var centre := lerpf(from_hz, to_hz, u)
		var x := randf() * 2.0 - 1.0
		low = lerpf(low, x, clampf(TAU * centre * 1.6 / RATE, 0.0, 1.0))
		high = lerpf(high, x, clampf(TAU * centre * 0.6 / RATE, 0.0, 1.0))
		out[i] = sin(PI * u) * sin(PI * u) * (low - high) * 3.0
	return out


## The sound a giant's attack makes as it goes out, hit or miss: a slam for
## blows that strike the ground, a whoosh for the rest; "" for none.
static func giant_cue(id: StringName) -> String:
	if id in [&"stomp", &"left_slam", &"right_slam", &"dive", &"pounce"]:
		return "giant_slam"
	if id in [&"lightning", &"bone_rain"]:
		return ""
	return "giant_swing"


## A blow: a low thump and a short crack of noise.
func _strike(seconds: float, thump: float, thump_decay: float, crack_decay: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var low := 0.0
	for i in n:
		var t := float(i) / RATE
		low = lerpf(low, randf() * 2.0 - 1.0, 0.35)
		out[i] = 0.7 * exp(-t / thump_decay) * sin(TAU * thump * t * (1.0 - 0.3 * t / seconds)) + 0.5 * exp(-t / crack_decay) * low
	return out


func _tone(seconds: float, f: float, decay: float, amp: float) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / RATE
		out[i] = amp * exp(-t / decay) * sin(TAU * f * t)
	return out


## A shamisen pluck: a plucked string (Karplus-Strong) with a bright attack,
## a quick fall in pitch after the plectrum (bachi) leaves it, and a buzz from
## a little noise fed back into the string (the sawari).
func _shamisen(f: float, seconds: float, amp := 0.55) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var period := maxi(int(RATE / f), 2)
	var line := PackedFloat32Array()
	line.resize(period)
	for i in period:
		line[i] = randf() * 2.0 - 1.0
	var k := 0
	var prev := 0.0
	for i in n:
		var cur := line[k]
		var nxt := line[(k + 1) % period]
		# Averaging damps the string; a touch of noise is the buzz.
		var v := 0.497 * (cur + nxt) + 0.004 * (randf() * 2.0 - 1.0) * absf(cur)
		line[k] = v
		k = (k + 1) % period
		var t := float(i) / RATE
		var bachi := 0.35 * exp(-t / 0.006) * (randf() * 2.0 - 1.0)
		out[i] = amp * (cur + 0.3 * (cur - prev)) + bachi * amp
		prev = cur
	return out


## A shakuhachi note: a breathy tone, the breath louder as it starts, with a
## vibrato that grows the longer it is held.
func _shakuhachi(f: float, seconds: float, amp := 0.32) -> PackedFloat32Array:
	var n := int(seconds * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	var breath := 0.0
	for i in n:
		var t := float(i) / RATE
		var env := minf(t / 0.12, 1.0) * minf((seconds - t) / 0.25, 1.0)
		var vib := 1.0 + 0.008 * minf(t / 0.8, 1.0) * sin(TAU * 5.2 * t)
		phase += TAU * f * vib / RATE
		breath = lerpf(breath, randf() * 2.0 - 1.0, 0.25)
		var air := 0.25 + 0.5 * exp(-t / 0.15)
		out[i] = amp * env * (sin(phase) + 0.18 * sin(2.0 * phase) + air * breath)
	return out


## A kotsuzumi stroke: the "pon", its pitch rising as the cords are squeezed.
func _kotsuzumi() -> PackedFloat32Array:
	var n := int(0.3 * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		phase += TAU * (300.0 + 220.0 * minf(t / 0.06, 1.0)) / RATE
		out[i] = 0.4 * exp(-t / 0.09) * sin(phase) + 0.15 * exp(-t / 0.008) * (randf() * 2.0 - 1.0)
	return out


func _normalised(out: PackedFloat32Array, to: float) -> PackedFloat32Array:
	var peak := 0.0
	for v in out:
		peak = maxf(peak, absf(v))
	if peak > to:
		for i in out.size():
			out[i] *= to / peak
	return out


## A taiko: a deep, falling tone and a slap of noise.
func _taiko(accent: float) -> PackedFloat32Array:
	var n := int(0.4 * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		phase += TAU * (55.0 + 70.0 * exp(-t / 0.05)) / RATE
		out[i] = accent * (0.9 * exp(-t / 0.16) * sin(phase) + 0.2 * exp(-t / 0.02) * (randf() * 2.0 - 1.0))
	return out


## A looping tune for the ensemble: four bars, played twice (the second time
## varied), in 8 eighth-notes a bar. The shamisen carries a phrase on the scale;
## the shakuhachi holds long notes over it; taiko marks the bars and kotsuzumi
## answers off the beat. The fight tune is quicker, denser and drives on the
## taiko; the menu tune is slow, with more flute and space. Seeded, so the same
## every time; sounds running past the end wrap onto the start, so the loop is
## seamless.
func _ensemble(fight: bool) -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7 if fight else 11
	var bpm := 132.0 if fight else 76.0
	var step := 60.0 / bpm / 2.0
	var bars := 8
	var eighths := bars * 8
	var n := int(eighths * step * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	# The scale over two octaves, low to high.
	var notes: Array[float] = []
	for octave in [1.0, 2.0, 4.0]:
		for f in SCALE:
			notes.append(f * octave)
	# A four-bar phrase of shamisen notes (scale degrees, -1 a rest).
	var phrase: Array[int] = []
	var degree := 5
	for k in 32:
		var plays := rng.randf() < (0.8 if fight else 0.5) or k % 8 == 0
		if plays:
			degree = clampi(degree + rng.randi_range(-2, 2), 3, 11)
			phrase.append(degree)
		else:
			phrase.append(-1)
	for k in eighths:
		var at := int(k * step * RATE)
		var bar := k / 8
		var beat := k % 8
		# Shamisen: the phrase, the second time through lifted at its cadences.
		var d: int = phrase[k % 32]
		if d >= 0:
			if bar >= 4 and beat == 6:
				d = mini(d + 2, notes.size() - 1)
			_add(out, _shamisen(notes[d], minf(step * 4.0, 1.4), 0.5 if beat % 2 == 0 else 0.38), at)
		# Shakuhachi: a long note at the start of every other bar (every bar in
		# the menu tune), on a high degree near the phrase.
		if beat == 0 and (bar % 2 == 0 or not fight):
			var held := clampi(phrase[(k + 2) % 32] if phrase[(k + 2) % 32] >= 0 else 8, 6, 12) + 2
			var length := step * (14.0 if fight else 7.0)
			_add(out, _shakuhachi(notes[mini(held, notes.size() - 1)], length, 0.42 if fight else 0.34), at)
		# Taiko: on the bar, and in the fight on every beat, doubled at the end.
		if beat == 0:
			_add(out, _taiko(1.0), at)
		elif fight and beat % 2 == 0:
			_add(out, _taiko(0.38), at)
		elif fight and bar % 4 == 3 and beat == 7:
			_add(out, _taiko(0.7), at)
		# Kotsuzumi: answers off the beat.
		if (fight and beat in [3, 7]) or (not fight and beat == 5 and bar % 2 == 1):
			_add(out, _kotsuzumi(), at)
	return _normalised(out, 0.85)


func _add(into: PackedFloat32Array, sound: PackedFloat32Array, at: int) -> void:
	for i in sound.size():
		into[(at + i) % into.size()] += sound[i]


func _wav(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		var v := clampf(samples[i], -1.0, 1.0)
		data.encode_s16(i * 2, int(v * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = samples.size()
	return w
