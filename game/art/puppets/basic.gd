extends RefCounted
## Basic rigs for the fighters not yet drawn in detail: each a description
## for the template (view, build, what the hands hold, headgear, appendages)
## with resting guards from the art direction. Their weapons are drawn only:
## until a fighter's moves are animated as swings, its hitboxes are its own.

const Template := preload("res://game/art/puppets/template.gd")


static func definition(id: StringName) -> PuppetDefinition:
	var spec := _spec(id)
	return Template.build(spec) if not spec.is_empty() else null


## tori warm, uke cool; anything not given falls back to the template's.
static func _palette(skin: String, tori: Dictionary, uke: Dictionary) -> Dictionary:
	var base := {skin = Color(skin), hair = Color("1b1614"), straw = Color("d8b46a"), lantern = Color("f3e3b0")}
	var t := base.duplicate()
	var u := base.duplicate()
	for k in tori:
		t[k] = Color(tori[k])
	for k in uke:
		u[k] = Color(uke[k])
	return {tori = t, uke = u}


static func _spread(prefix: String, count: int, from: float, to: float, extra := {}) -> Dictionary:
	var out := extra.duplicate()
	for i in count:
		out["%s_%d" % [prefix, i + 1]] = lerpf(from, to, float(i) / maxf(count - 1, 1))
	return out


## A spider's legs: each rises to a knee up and behind, then drops to a foot
## out behind, the set fanning from low to high.
static func _spider_legs(count: int, extra: Dictionary) -> Dictionary:
	var out := extra.duplicate()
	for i in count:
		var f := float(i) / maxf(count - 1, 1)
		var knee := lerpf(75.0, 175.0, f)
		var foot := lerpf(15.0, 75.0, f)
		out["spider_%d" % (i + 1)] = knee
		out["spider_%d_foot" % (i + 1)] = foot - knee
	return out


static func _spec(id: StringName) -> Dictionary:
	var stance := {lead_thigh = -24.0, lead_shin = 16.0, trail_thigh = 28.0, trail_shin = 6.0, torso = 6.0}
	var r := func(extra: Dictionary) -> Dictionary:
		var out := stance.duplicate()
		out.merge(extra, true)
		return out
	match id:
		&"kojiro":
			# Waki-gamae, the tail guard: the long blade low behind him.
			return {view = "side", hair = "tied", weapon = {type = "nodachi", hand = "trail"},
				rest = r.call({trail_upper = 30.0, trail_fore = -10.0, trail_weapon = 46.0, lead_upper = -20.0, lead_fore = -50.0}),
				colours = _palette("f0dcc2", {garment = "8f3a4f", secondary = "ede4cf", accent = "c9a23a", gear = "c9a23a"},
					{garment = "35406b", secondary = "b6b2aa", accent = "c0c6cc", gear = "c0c6cc"})}
		&"tomoe":
			# The naginata held low and forward.
			return {view = "side", hair = "long", weapon = {type = "naginata", hand = "lead"},
				rest = r.call({lead_upper = -45.0, lead_fore = -30.0, lead_weapon = -40.0, trail_upper = -10.0, trail_fore = -60.0}),
				colours = _palette("f2dfc8", {garment = "c0392b", secondary = "f0e7d3", accent = "c9a23a"},
					{garment = "2b4a6b", secondary = "c9ccd2", accent = "c0c6cc"})}
		&"benkei":
			# The great warrior monk: the polearm shouldered, a monk's hood.
			return {view = "diagonal", build = 1.25, hat = "hood", hair = "none", weapon = {type = "naginata", hand = "trail"},
				rest = r.call({trail_upper = -15.0, trail_fore = -110.0, trail_weapon = -94.0, lead_upper = -50.0, lead_fore = -90.0}),
				colours = _palette("e9cfb0", {garment = "2a2524", secondary = "e9e2d2", accent = "b8392a"},
					{garment = "2a2d3a", secondary = "d7d9de", accent = "3c5a8f"})}
		&"hanzo":
			# Low, the blade reversed along his forearm, hooded.
			return {view = "side", hat = "hood", hair = "none", weapon = {type = "reverse_blade", hand = "lead"},
				rest = r.call({lead_upper = -60.0, lead_fore = -100.0, trail_upper = -30.0, trail_fore = -110.0,
					lead_thigh = -34.0, lead_shin = 30.0, trail_thigh = 36.0, trail_shin = 12.0, torso = 14.0}),
				colours = _palette("e8cfb2", {garment = "26262c", secondary = "34343c", accent = "b8392a", paper = "1d1d22"},
					{garment = "22262e", secondary = "30353f", accent = "3a5a9a", paper = "1a1d24"})}
		&"monk":
			# En no Gyōja: the ringed staff planted, the other hand in a mudra.
			return {view = "diagonal", hat = "tokin", hair = "short", weapon = {type = "staff", hand = "lead"},
				rest = r.call({lead_upper = -30.0, lead_fore = -50.0, lead_weapon = 76.0, trail_upper = -40.0, trail_fore = -130.0}),
				colours = _palette("e8cdb0", {garment = "e9e1cf", secondary = "d97a2b", accent = "b8392a", gear = "c9a23a"},
					{garment = "d9dbe0", secondary = "6a7fa8", accent = "3a5a9a", gear = "c0c6cc"})}
		&"miko":
			# Izumo no Okuni: dancer's fan raised, a talisman in the other hand.
			return {view = "diagonal", hair = "long", weapon = {type = "fan", hand = "lead"}, off_hand = {type = "ofuda", hand = "trail"},
				rest = r.call({lead_upper = -60.0, lead_fore = -70.0, trail_upper = 10.0, trail_fore = -60.0}),
				colours = _palette("f3e2cf", {garment = "c0392b", secondary = "f2eee6", accent = "c9a23a"},
					{garment = "2b4a7a", secondary = "e6e9ee", accent = "c0c6cc"})}
		&"onmyoji":
			# Abe no Seimei: a talisman raised, in his tall cap and wide sleeves.
			return {view = "side", hat = "eboshi", hair = "none", sleeves = true, weapon = {type = "ofuda", hand = "lead"},
				rest = r.call({lead_upper = -100.0, lead_fore = -40.0, trail_upper = 10.0, trail_fore = -40.0}),
				colours = _palette("f2e0cb", {garment = "ece4d0", secondary = "f6f1e6", accent = "b8392a"},
					{garment = "9fb0c8", secondary = "e3e7ee", accent = "2b3f6e"})}
		&"kitsune":
			# Tamamo-no-Mae: court robes, nine tails fanned behind her.
			return {view = "diagonal", hair = "long", sleeves = true, tails = 9, tail = "fox",
				rest = r.call(_spread("tail", 9, 100.0, 172.0, {lead_upper = -55.0, lead_fore = -80.0, trail_upper = 15.0, trail_fore = -50.0})),
				colours = _palette("f3e6d6", {garment = "b8392a", secondary = "f2e2b8", accent = "c9a23a", extra = "f2e6c8"},
					{garment = "2f3f6e", secondary = "dfe3ea", accent = "c0c6cc", extra = "e6e9ee"})}
		&"tengu":
			# Sōjōbō: wings half spread, the long nose, the feather fan raised.
			return {view = "side", hat = "tokin", hair = "long", nose = "tengu", wings = true, weapon = {type = "feather_fan", hand = "lead"},
				rest = r.call({lead_upper = -110.0, lead_fore = -30.0, trail_upper = 10.0, trail_fore = -50.0, lead_wing = 145.0, trail_wing = 162.0}),
				colours = _palette("c0392b", {garment = "e9e1cf", secondary = "d97a2b", accent = "b8392a", extra = "3b2f2a"},
					{garment = "d9dbe0", secondary = "6a7fa8", accent = "3a5a9a", extra = "2a2f3a", skin = "8a3a40"})}
		&"kappa":
			# Kawatarō: a sumo's low, wide stance, shell on his back, water dish on his head.
			return {view = "diagonal", build = 1.3, hat = "dish", hair = "short", shell = true,
				rest = {torso = 10.0, lead_thigh = -40.0, lead_shin = 34.0, trail_thigh = 40.0, trail_shin = 10.0,
					lead_upper = -40.0, lead_fore = -60.0, trail_upper = -20.0, trail_fore = -70.0},
				colours = _palette("5f8f4e", {garment = "5f8f4e", secondary = "6f9f5e", accent = "c9a23a", extra = "6b5a2e", paper = "dfe8d0"},
					{garment = "4f7f8f", secondary = "5f8f9f", accent = "c0c6cc", extra = "4a5a4e", paper = "d8e4e8", skin = "4f7f8f"})}
		&"yuki_onna":
			# O-Yuki: a long white kimono to the floor, trailing sleeves, streaming hair.
			return {view = "side", hair = "long", hem = true, sleeves = true,
				rest = r.call({lead_upper = -70.0, lead_fore = -40.0, trail_upper = 10.0, trail_fore = -30.0}),
				colours = _palette("f4f2f0", {garment = "f2f1ee", secondary = "f7f6f3", accent = "c0392b", hair = "15151c"},
					{garment = "dde6f0", secondary = "eef3f8", accent = "8fa3c0", hair = "15151c"})}
		&"jorogumo":
			# A woman above, a spider's legs spread behind her.
			# Hair tied up, so it never merges with the legs behind her.
			return {view = "diagonal", hair = "tied", spider_legs = 4,
				rest = r.call(_spider_legs(8, {lead_upper = -60.0, lead_fore = -60.0, trail_upper = 20.0, trail_fore = -50.0})),
				# The jorōgumo spider's legs are yellow, banded with black: distinct
				# from her hair at any size.
				colours = _palette("f1e1d2", {garment = "8a2f3a", secondary = "f0e4d6", accent = "c9a23a", extra = "c9a032"},
					{garment = "2f3a5a", secondary = "e4e7ec", accent = "c0c6cc", extra = "9aa3ad"})}
		&"rokurokubi":
			# A kimono to the floor, a lantern in her hand, and a neck that stretches;
			# while her head is away the neck alone remains.
			return {view = "side", hair = "long", hem = true, neck = true, weapon = {type = "lantern", hand = "lead"},
				hides_head_during = &"long_neck",
				rest = r.call({lead_upper = -50.0, lead_fore = -40.0, trail_upper = 10.0, trail_fore = -40.0}),
				colours = _palette("f3e4d4", {garment = "a8432e", secondary = "f0e6d4", accent = "c9a23a"},
					{garment = "3a4f7a", secondary = "e3e6ec", accent = "c0c6cc"})}
		&"tanuki":
			# Danzaburō-danuki: great belly, straw hat, a sake flask, a thick tail.
			return {view = "diagonal", build = 1.4, belly = true, hat = "kasa", hair = "none", tails = 1, tail = "tanuki",
				weapon = {type = "flask", hand = "trail"},
				rest = r.call({tail_1 = 60.0, lead_upper = -50.0, lead_fore = -80.0, trail_upper = 10.0, trail_fore = -40.0}),
				colours = _palette("d8c2a0", {garment = "7a5a3e", secondary = "8a6a4a", accent = "c9a23a", extra = "6a4a30", gear = "c9a46a"},
					{garment = "6a6a72", secondary = "7a7a82", accent = "c0c6cc", extra = "55555c", gear = "b8b8c0", skin = "d0d0d6"})}
	return {}
