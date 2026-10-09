extends RefCounted
## Builds a puppet on the humanoid rig from a short description: plain body
## shapes in proportion, plus the few things that make each fighter
## recognisable. Detail comes character by character.
##
## A description (all optional except colours):
##   view = "side" | "diagonal";  lead_near (side view) = true
##   build = width scale;  head = head scale
##   weapon = {type, hand = "lead" | "trail", length, two_handed}  types: blade,
##            nodachi, naginata, staff, short_blade, dagger, fan, feather_fan,
##            ofuda, lantern (on a stick, hanging), flask. A two-handed weapon
##            is gripped by the other hand too, which slides along its grip.
##   off_hand = a second item for the other hand (same form)
##   hat = eboshi | tokin | kasa | hood | dish | none;  hair = short | long | tied | none
##   ears = "fox" | "tanuki";  nose = "tengu"
##   face = a feature or a list of them: fox (kitsune markings), beak, beard,
##          mask (a cloth over the lower face), makeup (red lips on white),
##          ohaguro (blackened teeth), stubble, moustache, brows (heavy),
##          patches (a tanuki's dark eye patches), lips (in the "lips" colour),
##          spider_eyes (a row of small eyes across the brow)
##   hair also: ponytail (high) | bun (with a hairpin) | long_front (falling
##          over the face);  headband = true
##   tails = count;  tail = "fox" | "tanuki";  wings = scale (0 for none);  shell = true
##   belly = true;  sleeves = true;  neck = true
##   hem = "robe" (covering the legs, not the feet; wide below and toward the
##         back; jointed at the knee, for kneeling) | "dress" (to the knee)
##   gait = "stride" | "shuffle";  crouch_pose, air_pose = leg angles for legs
##         that are not human
##   spider = true: the legs are a spider's, each with a leg branching before
##            and behind, and two more trailing low from the hips
##   leaf = move id during which a leaf shows on the forehead
##   rest = angles, ik and aim;  swings, weapons, props, hidden_during: as for any puppet
##   hides_head_during = move id;  colours = {tori = {...}, uke = {...}}

const P := PuppetDefinition.Part
const K := PuppetDefinition.Kind
const V := PuppetDefinition.View


static func build(spec: Dictionary) -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 170.0
	var w: float = spec.get("build", 1.0)
	var hs: float = spec.get("head", 1.0)
	d.view = V.DIAGONAL if spec.get("view", "side") == "diagonal" else V.SIDE
	d.side_lead_near = spec.get("lead_near", true)
	var anchors := {lead_shoulder = Vector2(5 * w, -52), trail_shoulder = Vector2(-5 * w, -52),
			lead_hip = Vector2(5 * w, 6), trail_hip = Vector2(-5 * w, 6), neck = Vector2(1, -57)}
	if d.view == V.DIAGONAL:
		anchors = {lead_shoulder = Vector2(20 * w, -52), trail_shoulder = Vector2(-19 * w, -52),
				lead_hip = Vector2(10 * w, 8), trail_hip = Vector2(-10 * w, 8), neck = Vector2(2, -56)}
	d.anchors = {d.view: anchors}
	var parts: Array = []
	parts.append(P.new("hips", "", Vector2(0, -84), {
			"side": _sx([Vector2(-15, -6), Vector2(16, -6), Vector2(20, 12), Vector2(-18, 12)], w),
			"front": _sx([Vector2(-22, -6), Vector2(22, -6), Vector2(24, 12), Vector2(-24, 12)], w)}, "garment", K.CLOTHING))
	parts.append(P.new("torso", "hips", Vector2(0, -4), {
			"side": _sx([Vector2(-12, 0), Vector2(13, 0), Vector2(16, -28), Vector2(13, -56), Vector2(-12, -56), Vector2(-14, -30)], w),
			"front": _sx([Vector2(-20, 0), Vector2(20, 0), Vector2(26, -56), Vector2(-25, -56)], w)}, "secondary", K.BODY))
	if spec.get("belly", false):
		parts.append(P.new("belly", "torso", Vector2.ZERO, _sx([Vector2(-6, -40), Vector2(14, -44), Vector2(30, -24), Vector2(26, -2), Vector2(4, 4), Vector2(-10, -10)], w), "belly", K.DECO))
	var head_parent := "torso"
	var head_at: Variant = "neck"
	if spec.get("neck", false):
		parts.append(P.new("neck", "torso", Vector2(1, -56), [Vector2(-4, 2), Vector2(4, 2), Vector2(4, -10), Vector2(-4, -10)], "skin", K.BODY))
		head_parent = "neck"
		head_at = Vector2(0, -9)
	parts.append(P.new("head", head_parent, head_at, _s([Vector2(-10, 0), Vector2(10, 0), Vector2(13, -14), Vector2(11, -26), Vector2(1, -31), Vector2(-9, -27), Vector2(-12, -14)], hs), "skin", K.HEAD))
	_hair(parts, spec.get("hair", "short"), hs)
	if spec.get("headband", false):
		parts.append(P.new("headband", "head", Vector2.ZERO, _s([Vector2(-13, -19), Vector2(12, -22), Vector2(12, -18), Vector2(-13, -15)], hs), "band", K.DECO))
		parts.append(P.new("headband_tails", "head", _s1(Vector2(-12, -18), hs), _s([Vector2(0, 0), Vector2(-14, 6), Vector2(-20, 14), Vector2(-12, 8), Vector2(0, 4)], hs), "band", K.DECO))
	_ears(parts, spec.get("ears", ""), hs)
	_hat(parts, spec.get("hat", "none"), hs)
	if spec.get("nose", "") == "tengu":
		parts.append(P.new("nose", "head", Vector2.ZERO, _s([Vector2(10, -19), Vector2(30, -15), Vector2(10, -12)], hs), "skin", K.DECO))
	if spec.has("leaf"):
		parts.append(P.new("leaf", "head", _s1(Vector2(6, -24), hs), [Vector2(0, 0), Vector2(6, -6), Vector2(14, -6), Vector2(18, 0), Vector2(10, 4)], "leaf", K.DECO))
		d.props = {leaf = [spec.leaf]}
	parts.append(P.new("sash", "torso", Vector2.ZERO, {"side": _sx([Vector2(-13, 3), Vector2(14, 3), Vector2(15, -8), Vector2(-14, -8)], w),
			"front": _sx([Vector2(-21, 3), Vector2(21, 3), Vector2(22, -8), Vector2(-21, -8)], w)}, "accent", K.CLOTHING))
	match spec.get("hem", ""):
		"robe":
			# Built each frame around the legs (waist, knees, ankles), so it
			# covers both legs to just above the feet whatever they do: walking,
			# crouching, kneeling, leaping.
			var robe := P.new("hem", "hips", Vector2.ZERO, [Vector2(-17, -6), Vector2(19, -6), Vector2(30, 76), Vector2(-38, 76)], "garment", K.CLOTHING)
			robe.wraps = "ankle"
			parts.append(robe)
		"dress":
			parts.append(P.new("hem", "hips", Vector2.ZERO, {"side": _sx([Vector2(-15, -6), Vector2(17, -6), Vector2(24, 46), Vector2(-28, 46)], w),
					"front": _sx([Vector2(-23, -6), Vector2(23, -6), Vector2(28, 46), Vector2(-30, 46)], w)}, "garment", K.CLOTHING))
			d.follows["hem"] = {joints = ["lead_thigh", "trail_thigh"], lead = 0.5, scale = 0.5}
	if spec.get("spider", false):
		_spider_legs(parts, d, w)
	else:
		for side in ["lead", "trail"]:
			parts.append(P.new(side + "_thigh", "hips", side + "_hip", _sx([Vector2(-10, 0), Vector2(10, 0), Vector2(12, 42), Vector2(-12, 42)], w), "garment", K.LEG))
			parts.append(P.new(side + "_shin", side + "_thigh", Vector2(0, 40), _sx([Vector2(-9, 0), Vector2(9, 0), Vector2(10, 37), Vector2(-10, 37)], w), "garment", K.LEG))
			parts.append(P.new(side + "_foot", side + "_shin", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "skin", K.LEG))
	for side in ["lead", "trail"]:
		parts.append(P.new(side + "_upper", "torso", side + "_shoulder", _sx([Vector2(-7, 0), Vector2(8, 0), Vector2(9, 30), Vector2(-7, 29)], w), "garment", K.ARM_UPPER))
		parts.append(P.new(side + "_fore", side + "_upper", Vector2(1, 29), _sx([Vector2(-4, 0), Vector2(5, 0), Vector2(4, 22), Vector2(-3, 22)], w), "skin", K.ARM_FORE))
		if spec.get("sleeves", false):
			parts.append(P.new(side + "_sleeve", side + "_fore", Vector2(0, 2), [Vector2(-6, 0), Vector2(8, 0), Vector2(12, 34), Vector2(-4, 40)], "garment", K.DECO))
		parts.append(P.new(side + "_hand", side + "_fore", Vector2(0, 22), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 7), Vector2(-4, 7)], "skin", K.HAND))
	_appendages(parts, spec, w)
	d.parts = parts
	var weapon: Dictionary = spec.get("weapon", {})
	if not weapon.is_empty():
		_item(d, weapon)
		d.attack_arm = weapon.get("hand", "lead")
	var off: Dictionary = spec.get("off_hand", {})
	if not off.is_empty():
		_item(d, off)
	d.face_teru = [[[Vector2(-1, -20), Vector2(8, -22), Vector2(9, -20), Vector2(0, -18)], "ink"],
			[[Vector2(2, -16), Vector2(8, -17), Vector2(9, -15), Vector2(3, -14)], "ink"],
			[[Vector2(3, -6), Vector2(9, -7), Vector2(9, -5), Vector2(3, -5)], "ink"]]
	d.face_kumoru = [[[Vector2(-1, -17), Vector2(8, -18), Vector2(9, -16), Vector2(0, -15)], "ink"],
			[[Vector2(2, -14), Vector2(9, -14), Vector2(9, -13), Vector2(2, -13)], "ink"],
			[[Vector2(3, -5), Vector2(9, -4), Vector2(9, -3), Vector2(3, -4)], "ink"]]
	# Features that make each face its own: some lie under the eyes (patches,
	# a mask's cloth over the mouth is over them), some over.
	var styles: Variant = spec.get("face", [])
	var features: Array = [styles] if styles is String else styles
	var under: Array = []
	var over: Array = []
	for f in features:
		match f:
			"fox":
				over += [[[Vector2(0, -22), Vector2(10, -27), Vector2(11, -24), Vector2(2, -20)], "mark"],
						[[Vector2(4, -11), Vector2(12, -12), Vector2(11, -9), Vector2(4, -9)], "mark"]]
			"patches":
				under.append([[Vector2(-1, -21), Vector2(11, -22), Vector2(12, -12), Vector2(0, -11)], "patch"])
			"stubble":
				under.append([[Vector2(-7, -1), Vector2(11, -1), Vector2(13, -9), Vector2(8, -11), Vector2(-3, -9)], "stubble"])
			"beak":
				# Two triangles: the smaller lower mandible, then the larger upper
				# one over it, overlapping.
				over.append([[Vector2(8, -8), Vector2(18, -5), Vector2(8, -2)], "beak_low"])
				over.append([[Vector2(7, -13), Vector2(22, -9), Vector2(8, -6)], "beak"])
			"beard":
				over.append([[Vector2(1, -7), Vector2(11, -7), Vector2(9, 6), Vector2(3, 18), Vector2(-4, 6)], "beard"])
			"moustache":
				over.append([[Vector2(5, -9), Vector2(12, -9), Vector2(14, -5), Vector2(11, -7), Vector2(5, -7)], "ink"])
			"brows":
				over.append([[Vector2(-2, -22), Vector2(11, -25), Vector2(12, -21), Vector2(-1, -19)], "ink"])
			"mask":
				over.append([[Vector2(-11, -12), Vector2(14, -12), Vector2(13, 1), Vector2(-11, 1)], "black"])
			"makeup":
				over.append([[Vector2(5, -7), Vector2(10, -7), Vector2(10, -4), Vector2(5, -4)], "lips"])
			"lips":
				over.append([[Vector2(4, -7), Vector2(10, -7), Vector2(10, -4), Vector2(4, -4)], "lips"])
			"ohaguro":
				over.append([[Vector2(4, -7), Vector2(10, -7), Vector2(10, -4), Vector2(4, -4)], "black"])
			"spider_eyes":
				for k in 4:
					var x := -1.0 + k * 3.5
					over.append([[Vector2(x, -27), Vector2(x + 2, -27), Vector2(x + 2, -25), Vector2(x, -25)], "spider_eye"])
	# A beak takes the place of the mouth.
	var teru: Array = d.face_teru
	var kumoru: Array = d.face_kumoru
	if "beak" in features:
		teru = teru.slice(0, 2)
		kumoru = kumoru.slice(0, 2)
	d.face_teru = under + teru + over
	d.face_kumoru = under + kumoru + over
	d.points = {mouth = ["head", Vector2(10, -8)], before = ["torso", Vector2(38, -22)]}
	var common := {ink = Color("141010"), face = Color("f5f0e6"), steel = Color("dde2e6"), paper = Color("f4efe3"),
			wood = Color("6b4a2e"), black = Color("1d1818"), mark = Color("c3261c"), leaf = Color("5f8f3e"),
			belly = Color("e6d2b0"), beak = Color("c9b24a"), beak_low = Color("8f7d2a"), beard = Color("ece7dc"), lips = Color("b8322a"),
			stubble = Color("6b5446"), patch = Color("3b2a20"), spider_eye = Color("8a1020"), band = Color("c0392b")}
	var tori: Dictionary = common.duplicate()
	tori.merge(spec.colours.tori, true)
	var uke: Dictionary = common.duplicate()
	uke.merge(spec.colours.uke, true)
	d.colourways = [tori, uke]
	# In profile, the near arm rests low (guarding the belly, ready to come
	# up) and the far arm high (guarding the face, ready to jab); no arm rests
	# behind. A description's own rest goes over this.
	var guard := {}
	if d.view == V.SIDE:
		var near := "lead" if d.side_lead_near else "trail"
		var far := "trail" if d.side_lead_near else "lead"
		guard = {near + "_upper": -40.0, near + "_fore": -70.0, far + "_upper": -55.0, far + "_fore": -110.0}
	guard.merge(spec.get("rest", {}), true)
	d.rest = guard
	# Its attacks from the verbs, under the shared conventions; a description's
	# own swings (signature moves) go over them.
	var custom: Dictionary = spec.get("swings", {})
	var traced := spec.duplicate()
	traced["traced"] = true
	d.swings = Verbs.kit(d, traced)
	d.swings.merge(custom, true)
	d.gait = spec.get("gait", "stride")
	d.crouch_pose = spec.get("crouch_pose", {})
	d.air_pose = spec.get("air_pose", {})
	for given in spec.get("weapons", []):
		d.weapons.append(given)
	for key in ["props", "hidden_during"]:
		var extra: Dictionary = spec.get(key, {})
		var have: Dictionary = d.get(key)
		have.merge(extra, true)
	if spec.has("hides_head_during"):
		d.hidden_during["head"] = [[spec.hides_head_during, 1.0, 3.0]]
	return d


static func _hair(parts: Array, style: String, hs: float) -> void:
	var cap := [Vector2(-12, -12), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(11, -24), Vector2(-4, -26), Vector2(-8, -14), Vector2(-14, -4)]
	match style:
		"short":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s(cap, hs), "hair", K.DECO))
		"tied":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s(cap, hs), "hair", K.DECO))
			parts.append(P.new("tail_of_hair", "head", _s1(Vector2(-11, -24), hs), _s([Vector2(0, 0), Vector2(-6, 2), Vector2(-14, 30), Vector2(-8, 32), Vector2(-2, 8)], hs), "hair", K.DECO))
		"long":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s([Vector2(-12, -10), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(12, -20), Vector2(4, -26), Vector2(-6, -22), Vector2(-10, 6), Vector2(-14, 40), Vector2(-20, 38), Vector2(-16, 0)], hs), "hair", K.DECO))
		"long_front":
			# Long hair, with strands falling forward over the face.
			parts.append(P.new("hair", "head", Vector2.ZERO, _s([Vector2(-12, -10), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(12, -20), Vector2(4, -26), Vector2(-6, -22), Vector2(-10, 6), Vector2(-14, 40), Vector2(-20, 38), Vector2(-16, 0)], hs), "hair", K.DECO))
			parts.append(P.new("hair_front", "head", Vector2.ZERO, _s([Vector2(5, -29), Vector2(12, -24), Vector2(13, 2), Vector2(10, 10), Vector2(9, -18)], hs), "hair", K.DECO))
		"ponytail":
			# Gathered high at the crown and falling back in a long tail.
			parts.append(P.new("hair", "head", Vector2.ZERO, _s(cap, hs), "hair", K.DECO))
			parts.append(P.new("tail_of_hair", "head", _s1(Vector2(-6, -32), hs), _s([Vector2(0, 0), Vector2(-4, -6), Vector2(-22, 6), Vector2(-30, 30), Vector2(-22, 26), Vector2(-10, 6)], hs), "hair", K.DECO))
		"bun":
			# Hair up in a bun, a hairpin through it.
			parts.append(P.new("hair", "head", Vector2.ZERO, _s(cap, hs), "hair", K.DECO))
			var bun := []
			for k in 10:
				var a := k * TAU / 10.0
				bun.append(Vector2(-8, -33) + Vector2(cos(a) * 9.0, sin(a) * 7.0))
			parts.append(P.new("bun", "head", Vector2.ZERO, _s(bun, hs), "hair", K.DECO))
			parts.append(P.new("hairpin", "head", Vector2.ZERO, _s([Vector2(-20, -38), Vector2(4, -30), Vector2(4, -28), Vector2(-20, -36)], hs), "gear", K.DECO))


static func _ears(parts: Array, ears: String, hs: float) -> void:
	match ears:
		"fox":
			parts.append(P.new("ear_b", "head", Vector2.ZERO, _s([Vector2(-8, -27), Vector2(-12, -44), Vector2(-2, -31)], hs), "hair", K.DECO))
			parts.append(P.new("ear_f", "head", Vector2.ZERO, _s([Vector2(1, -31), Vector2(4, -48), Vector2(9, -29)], hs), "hair", K.DECO))
		"tanuki":
			parts.append(P.new("ear_b", "head", Vector2.ZERO, _s([Vector2(-10, -24), Vector2(-12, -33), Vector2(-4, -30)], hs), "garment", K.DECO))
			parts.append(P.new("ear_f", "head", Vector2.ZERO, _s([Vector2(2, -30), Vector2(6, -37), Vector2(9, -28)], hs), "garment", K.DECO))


## Hats pivot at the crown, so a rest angle can push one back.
static func _hat(parts: Array, hat: String, hs: float) -> void:
	var shape := []
	var slot := "black"
	match hat:
		"eboshi":
			shape = [Vector2(-9, 3), Vector2(7, 0), Vector2(10, -18), Vector2(-1, -20)]
		"tokin":
			shape = [Vector2(-5, 0), Vector2(6, -1), Vector2(4, -9), Vector2(-4, -9)]
		"kasa":
			shape = [Vector2(-26, 6), Vector2(26, 6), Vector2(4, -10), Vector2(-4, -10)]
			slot = "straw"
		"hood":
			shape = [Vector2(-13, 24), Vector2(-12, 2), Vector2(0, -5), Vector2(12, 0), Vector2(13, 8), Vector2(6, 2), Vector2(-6, 6), Vector2(-8, 30)]
			slot = "paper"
		"dish":
			shape = [Vector2(-10, 0), Vector2(10, -1), Vector2(8, -4), Vector2(-8, -4)]
			slot = "paper"
		_:
			return
	parts.append(P.new("hat", "head", _s1(Vector2(0, -30), hs), _s(shape, hs), slot, K.DECO))


## A spider's legs in place of a woman's: each leg with a leg branching off
## before and behind it, and two more trailing low from the hips. They are
## not human legs, so their knees are free.
static func _spider_legs(parts: Array, d: PuppetDefinition, w: float) -> void:
	var leg := [Vector2(-3, 0), Vector2(3, 0), Vector2(2.5, 44), Vector2(-2.5, 44)]
	var foot := [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(0.8, 42), Vector2(-0.8, 42)]
	for side in ["lead", "trail"]:
		parts.append(P.new(side + "_thigh", "hips", side + "_hip", leg, "extra", K.LEG))
		parts.append(P.new(side + "_shin", side + "_thigh", Vector2(0, 42), foot, "extra", K.LEG))
		parts.append(P.new(side + "_foot", side + "_shin", Vector2(0, 40), [Vector2(-1, 0), Vector2(4, 0), Vector2(4, 2), Vector2(-1, 2)], "extra", K.LEG))
		for branch in ["before", "behind"]:
			var name := "%s_%s" % [side, branch]
			parts.append(P.new(name, side + "_thigh", Vector2(0, 4), leg, "extra", K.DECO))
			parts.append(P.new(name + "_foot", name, Vector2(0, 42), foot, "extra", K.DECO))
	for i in 2:
		var name := "rear_%d" % (i + 1)
		parts.append(P.new(name, "hips", Vector2(-12 * w, 4 + 3 * i), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(2, 48), Vector2(-2, 48)], "extra", K.APPENDAGE))
		parts.append(P.new(name + "_foot", name, Vector2(0, 46), foot, "extra", K.DECO))
	d.limits = {fore = [-160.0, 0.0]}


static func _appendages(parts: Array, spec: Dictionary, w: float) -> void:
	var tails: int = spec.get("tails", 0)
	var tail_shape := [Vector2(-4, 0), Vector2(4, 0), Vector2(10, 22), Vector2(8, 46), Vector2(0, 58), Vector2(-8, 46), Vector2(-10, 22)]
	if spec.get("tail", "fox") == "tanuki":
		tail_shape = [Vector2(-6, 0), Vector2(6, 0), Vector2(12, 20), Vector2(10, 40), Vector2(0, 48), Vector2(-10, 40), Vector2(-12, 20)]
	for i in tails:
		parts.append(P.new("tail_%d" % (i + 1), "hips", Vector2(-14 * w, 4), tail_shape, "extra", K.APPENDAGE))
	var wings: float = spec.get("wings", 0.0)
	if wings > 0.0:
		# Rooted broad at the shoulder blades, so they grow from the back.
		var wing := _s([Vector2(-10, -4), Vector2(12, -4), Vector2(30, 40), Vector2(26, 80), Vector2(10, 96), Vector2(-4, 70), Vector2(-12, 20)], wings)
		parts.append(P.new("lead_wing", "torso", Vector2(-6, -46), wing, "extra", K.APPENDAGE))
		parts.append(P.new("trail_wing", "torso", Vector2(-8, -44), wing, "extra", K.APPENDAGE))
	if spec.get("shell", false):
		parts.append(P.new("shell", "torso", Vector2(-10 * w, -30), _sx([Vector2(-14, -22), Vector2(-2, -28), Vector2(6, -20), Vector2(8, 0), Vector2(6, 24), Vector2(-6, 30), Vector2(-16, 22), Vector2(-18, 0)], w), "extra", K.APPENDAGE))


## A held thing on the given hand: its grip is the weapon part, the rest
## rides on it. A two-handed weapon is also gripped by the other hand.
## What strikes, for each held thing: a segment along (or across) it in its
## own space, its width, and where along it a blow is strongest.
static func _strikes_with(d: PuppetDefinition, name: String, bone: String, from: Vector2, to: Vector2, width: float, zones: Array) -> void:
	d.weapons.append({name = name, bone = bone, from = from, to = to, width = width, zones = zones})


static func _item(d: PuppetDefinition, item: Dictionary) -> void:
	var hand: String = item.get("hand", "lead")
	var edge := [[0.0, 0.25, 0.4], [0.25, 0.7, 0.8], [0.7, 1.0, 1.0]]
	var label: String = hand + "_" + String(item.type)
	var other := "trail" if hand == "lead" else "lead"
	var grip := hand + "_weapon"
	var at := hand + "_hand"
	var length: float = item.get("length", 0.0)
	match item.type:
		"blade", "short_blade", "dagger":
			var l: float = length if length > 0.0 else {"blade": 80.0, "short_blade": 52.0, "dagger": 30.0}[item.type]
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -4), Vector2(2.5, -4), Vector2(2.5, 10), Vector2(-2, 10)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_guard", grip, Vector2(0, 10), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 2.5), Vector2(-4, 2.5)], "gear", K.DECO))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, 12), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(1.5, l - 5), Vector2(-1, l), Vector2(-2, 3)], "steel", K.DECO))
			_strikes_with(d, label, grip, Vector2(0, 12), Vector2(0, 12 + l), 5.0, edge)
		"nodachi":
			# A long grip: the holding hand by the guard, the other further down.
			var l := length if length > 0.0 else 118.0
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2.5, -28), Vector2(2.5, -28), Vector2(2.5, 3), Vector2(-2.5, 3)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_guard", grip, Vector2(0, 3), [Vector2(-5, 0), Vector2(5, 0), Vector2(5, 3), Vector2(-5, 3)], "gear", K.DECO))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, 6), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, l - 6), Vector2(-1, l), Vector2(-2, 3)], "steel", K.DECO))
			d.grips[other] = {part = grip, from = Vector2(0, -24), to = Vector2(0, -8)}
			_strikes_with(d, label, grip, Vector2(0, 6), Vector2(0, 6 + l), 5.0, edge)
		"naginata", "staff":
			var shaft := length if length > 0.0 else 130.0
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -36), Vector2(2, -36), Vector2(2, shaft - 36), Vector2(-2, shaft - 36)], "wood", K.WEAPON))
			if item.type == "naginata":
				d.parts.append(P.new(grip + "_blade", grip, Vector2(0, shaft - 36), [Vector2(-3, 0), Vector2(4, 0), Vector2(7, 28), Vector2(0, 38), Vector2(-3, 10)], "steel", K.DECO))
				# The blade wounds most, the butt fairly, the shaft little.
				_strikes_with(d, label, grip, Vector2(0, -36), Vector2(0, shaft + 2), 6.0, [[0.0, 0.12, 0.7], [0.12, 0.76, 0.35], [0.76, 1.0, 1.0]])
			else:
				# The ring crowning the far end of the staff: a real ring, open in
				# the middle (a band, joined to the shaft where it is cut).
				var ring := PackedVector2Array()
				for k in 13:
					var a := PI / 2.0 + 0.35 + k * (TAU - 0.7) / 12.0
					ring.append(Vector2(cos(a), sin(a) + 1.0) * 12.0)
				for k in range(12, -1, -1):
					var a := PI / 2.0 + 0.35 + k * (TAU - 0.7) / 12.0
					ring.append(Vector2(cos(a), sin(a) + 1.0) * 12.0 * 0.62 + Vector2(0, 12.0 * 0.38))
				d.parts.append(P.new(grip + "_rings", grip, Vector2(0, shaft - 36), Array(ring), "gear", K.DECO))
				# The ringed end strikes hardest.
				_strikes_with(d, label, grip, Vector2(0, -36), Vector2(0, shaft - 12), 7.0, [[0.0, 0.12, 0.6], [0.12, 0.84, 0.45], [0.84, 1.0, 1.0]])
			if item.get("two_handed", false):
				d.grips[other] = {part = grip, from = Vector2(0, 26), to = Vector2(0, 66)}
		"kama":
			# A sickle: a short haft, its blade set across the end and hooking
			# back toward the hand. Its edge lies across the haft, so an aim names
			# where the blade points and the haft turns a quarter to match: held
			# with the haft up and a little forward, the blade points forward and
			# a little down.
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -6), Vector2(2, -6), Vector2(2, 30), Vector2(-2, 30)], "wood", K.WEAPON))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, 30), [Vector2(2, -3), Vector2(-26, -6), Vector2(-40, -16), Vector2(-30, -3), Vector2(2, 3)], "steel", K.DECO))
			d.aim_offsets[grip] = -90.0
			# Its blade wounds; its haft does not.
			_strikes_with(d, label, grip, Vector2(0, 30), Vector2(-40, 14), 6.0, [[0.0, 1.0, 1.0]])
		"straight_sword":
			# A straight, double-edged blade (not a katana).
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -4), Vector2(2.5, -4), Vector2(2.5, 10), Vector2(-2, 10)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_guard", grip, Vector2(0, 10), [Vector2(-7, 0), Vector2(7, 0), Vector2(7, 3), Vector2(-7, 3)], "gear", K.DECO))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, 13), [Vector2(-3, 0), Vector2(3, 0), Vector2(3, 58), Vector2(0, 66), Vector2(-3, 58)], "steel", K.DECO))
			_strikes_with(d, label, grip, Vector2(0, 13), Vector2(0, 79), 5.0, edge)
		"shuriken":
			d.parts.append(P.new(grip, at, Vector2(0, 6), [Vector2(0, -7), Vector2(2, -2), Vector2(7, 0), Vector2(2, 2), Vector2(0, 7), Vector2(-2, 2), Vector2(-7, 0), Vector2(-2, -2)], "steel", K.WEAPON))
		"claws":
			# Long nails: three blades from the fingers.
			d.parts.append(P.new(grip, at, Vector2(0, 6), [Vector2(-4, 0), Vector2(-2, 18), Vector2(0, 0), Vector2(2, 18), Vector2(4, 0)], item.get("slot", "nail"), K.WEAPON))
			_strikes_with(d, label, grip, Vector2(0, 0), Vector2(0, 18), 8.0, [[0.0, 1.0, 1.0]])
		"fan", "feather_fan":
			var slot := "extra" if item.type == "feather_fan" else "paper"
			d.parts.append(P.new(grip, at, Vector2(0, 5), [Vector2(-2, 0), Vector2(2, 0), Vector2(2, 6), Vector2(-2, 6)], "wood", K.WEAPON))
			d.parts.append(P.new(grip + "_leaf", grip, Vector2(0, 6), [Vector2(0, 0), Vector2(20, 18), Vector2(22, 30), Vector2(10, 38), Vector2(-10, 38), Vector2(-22, 30), Vector2(-20, 18)], slot, K.DECO))
			_strikes_with(d, label, grip, Vector2(0, 6), Vector2(0, 44), 24.0, [[0.0, 1.0, 0.8]])
		"ofuda":
			# A talisman: paper, red border, black strokes.
			d.parts.append(P.new(grip, at, Vector2(0, 5), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 16), Vector2(-4, 16)], "paper", K.WEAPON))
			d.parts.append(P.new(grip + "_mark", grip, Vector2(0, 2), [Vector2(-1, 0), Vector2(1, 0), Vector2(1, 12), Vector2(-1, 12)], "ink", K.DECO))
			d.parts.append(P.new(grip + "_border", grip, Vector2(0, 15), [Vector2(-4, -1), Vector2(4, -1), Vector2(4, 0), Vector2(-4, 0)], "mark", K.DECO))
			_strikes_with(d, label, grip, Vector2(0, 0), Vector2(0, 16), 8.0, [[0.0, 1.0, 0.6]])
		"lantern":
			# A paper lantern hanging from the end of a short stick.
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-1.2, -2), Vector2(1.2, -2), Vector2(1.2, 30), Vector2(-1.2, 30)], "wood", K.WEAPON))
			var body := P.new(grip + "_body", grip, Vector2(0, 30), [Vector2(-0.6, 0), Vector2(0.6, 0), Vector2(0.6, 6), Vector2(6, 6), Vector2(9, 12),
					Vector2(9, 22), Vector2(6, 30), Vector2(-6, 30), Vector2(-9, 22), Vector2(-9, 12), Vector2(-6, 6), Vector2(-0.6, 6)], "lantern", K.DECO)
			body.hangs = true
			d.parts.append(body)
			# The stick, and the lantern hanging from it, which strikes hardest.
			_strikes_with(d, label, grip, Vector2(0, 0), Vector2(0, 30), 4.0, [[0.0, 1.0, 0.5]])
			_strikes_with(d, label + "_body", grip + "_body", Vector2(0, 8), Vector2(0, 30), 18.0, [[0.0, 1.0, 1.0]])
		"flask":
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, 0), Vector2(2, 0), Vector2(3, 6), Vector2(-3, 6)], "gear", K.WEAPON))
			d.parts.append(P.new(grip + "_body", grip, Vector2(0, 6), [Vector2(-3, 0), Vector2(3, 0), Vector2(9, 12), Vector2(8, 22), Vector2(-8, 22), Vector2(-9, 12)], "gear", K.DECO))
			_strikes_with(d, label, grip, Vector2(0, 0), Vector2(0, 28), 16.0, [[0.0, 1.0, 0.8]])


static func _s(points: Array, k: float) -> Array:
	return points.map(func(p: Vector2) -> Vector2: return p * k)


static func _s1(p: Vector2, k: float) -> Vector2:
	return p * k


static func _sx(points: Array, k: float) -> Array:
	return points.map(func(p: Vector2) -> Vector2: return Vector2(p.x * k, p.y))
