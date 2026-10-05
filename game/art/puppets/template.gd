extends RefCounted
## Builds a basic puppet on the humanoid rig from a short description: plain
## body shapes in proportion, plus the few things that make each fighter
## recognisable. Detail comes later, character by character; this fixes the
## rig: the view, which hand holds what, and where appendages grow.
##
## A description (all optional except colours):
##   view = "side" | "diagonal"; lead_near (side view) = true
##   build = width scale; head = head scale
##   weapon = {type, hand = "lead" | "trail", length}  types: blade, nodachi,
##            naginata, staff, reverse_blade, fan, feather_fan, ofuda, lantern, flask
##   off_hand = a second, smaller item for the other hand (same form)
##   hat = eboshi | tokin | kasa | hood | dish | none;  hair = short | long | tied | none
##   nose = "tengu";  tails = count;  tail = "fox" | "tanuki";  wings = true
##   spider_legs = count per side;  shell = true;  belly = true;  sleeves = true
##   hem = true (a kimono reaching the floor over the legs);  neck = true (a
##   neck between torso and head, hidden while the head is away)
##   rest = joint angles;  hides_head_during = move id
##   colours = {tori = {...}, uke = {...}}: skin, garment, secondary, accent,
##            hair, gear, extra

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
	# Body.
	parts.append(P.new("hips", "", Vector2(0, -84), {
			"side": _sx([Vector2(-15, -6), Vector2(16, -6), Vector2(20, 12), Vector2(-18, 12)], w),
			"front": _sx([Vector2(-22, -6), Vector2(22, -6), Vector2(24, 12), Vector2(-24, 12)], w)}, "garment", K.CLOTHING))
	parts.append(P.new("torso", "hips", Vector2(0, -4), {
			"side": _sx([Vector2(-12, 0), Vector2(13, 0), Vector2(16, -28), Vector2(13, -56), Vector2(-12, -56), Vector2(-14, -30)], w),
			"front": _sx([Vector2(-20, 0), Vector2(20, 0), Vector2(26, -56), Vector2(-25, -56)], w)}, "secondary", K.BODY))
	if spec.get("belly", false):
		parts.append(P.new("belly", "torso", Vector2.ZERO, _sx([Vector2(-8, -40), Vector2(14, -44), Vector2(30, -24), Vector2(26, -2), Vector2(2, 4), Vector2(-12, -10)], w), "skin", K.DECO))
	var head_parent := "torso"
	var head_at: Variant = "neck"
	if spec.get("neck", false):
		parts.append(P.new("neck", "torso", Vector2(1, -56), [Vector2(-4, 2), Vector2(4, 2), Vector2(4, -10), Vector2(-4, -10)], "skin", K.BODY))
		head_parent = "neck"
		head_at = Vector2(0, -9)
	parts.append(P.new("head", head_parent, head_at, _s([Vector2(-10, 0), Vector2(10, 0), Vector2(13, -14), Vector2(11, -26), Vector2(1, -31), Vector2(-9, -27), Vector2(-12, -14)], hs), "skin", K.HEAD))
	_hair(parts, spec.get("hair", "short"), hs)
	_hat(parts, spec.get("hat", "none"), hs)
	if spec.get("nose", "") == "tengu":
		parts.append(P.new("nose", "head", Vector2.ZERO, _s([Vector2(10, -19), Vector2(32, -15), Vector2(10, -12)], hs), "skin", K.DECO))
	# Clothing over the waist.
	parts.append(P.new("sash", "torso", Vector2.ZERO, {"side": _sx([Vector2(-13, 3), Vector2(14, 3), Vector2(15, -8), Vector2(-14, -8)], w),
			"front": _sx([Vector2(-21, 3), Vector2(21, 3), Vector2(22, -8), Vector2(-21, -8)], w)}, "accent", K.CLOTHING))
	if spec.get("hem", false):
		parts.append(P.new("hem", "hips", Vector2.ZERO, {"side": _sx([Vector2(-17, -6), Vector2(18, -6), Vector2(26, 84), Vector2(-22, 84)], w),
				"front": _sx([Vector2(-23, -6), Vector2(23, -6), Vector2(30, 84), Vector2(-30, 84)], w)}, "garment", K.CLOTHING))
	# Legs, arms, hands.
	for side in ["lead", "trail"]:
		parts.append(P.new(side + "_thigh", "hips", side + "_hip", _sx([Vector2(-10, 0), Vector2(10, 0), Vector2(12, 42), Vector2(-12, 42)], w), "garment", K.LEG))
		parts.append(P.new(side + "_shin", side + "_thigh", Vector2(0, 40), _sx([Vector2(-9, 0), Vector2(9, 0), Vector2(10, 37), Vector2(-10, 37)], w), "garment", K.LEG))
		parts.append(P.new(side + "_foot", side + "_shin", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "skin", K.LEG))
		parts.append(P.new(side + "_upper", "torso", side + "_shoulder", _sx([Vector2(-7, 0), Vector2(8, 0), Vector2(9, 30), Vector2(-7, 29)], w), "garment", K.ARM_UPPER))
		parts.append(P.new(side + "_fore", side + "_upper", Vector2(1, 29), _sx([Vector2(-4, 0), Vector2(5, 0), Vector2(4, 22), Vector2(-3, 22)], w), "skin", K.ARM_FORE))
		if spec.get("sleeves", false):
			parts.append(P.new(side + "_sleeve", side + "_fore", Vector2(0, 2), [Vector2(-6, 0), Vector2(8, 0), Vector2(12, 34), Vector2(-4, 40)], "garment", K.DECO))
		parts.append(P.new(side + "_hand", side + "_fore", Vector2(0, 22), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 7), Vector2(-4, 7)], "skin", K.HAND))
	# Appendages, drawn behind everything.
	_appendages(parts, spec, w)
	d.parts = parts
	# What the hands hold.
	var weapon: Dictionary = spec.get("weapon", {})
	if not weapon.is_empty():
		_item(d, weapon)
		d.attack_arm = weapon.get("hand", "lead")
	var off: Dictionary = spec.get("off_hand", {})
	if not off.is_empty():
		_item(d, off)
	# A plain face, in profile.
	d.face_teru = [[[Vector2(-1, -20), Vector2(8, -22), Vector2(9, -20), Vector2(0, -18)], "ink"],
			[[Vector2(2, -16), Vector2(8, -17), Vector2(9, -15), Vector2(3, -14)], "ink"],
			[[Vector2(3, -6), Vector2(9, -7), Vector2(9, -5), Vector2(3, -5)], "ink"]]
	d.face_kumoru = [[[Vector2(-1, -17), Vector2(8, -18), Vector2(9, -16), Vector2(0, -15)], "ink"],
			[[Vector2(2, -14), Vector2(9, -14), Vector2(9, -13), Vector2(2, -13)], "ink"],
			[[Vector2(3, -5), Vector2(9, -4), Vector2(9, -3), Vector2(3, -4)], "ink"]]
	d.points = {mouth = ["head", Vector2(10, -8)]}
	var common := {ink = Color("141010"), face = Color("f5f0e6"), steel = Color("dde2e6"), paper = Color("f4efe3"),
			wood = Color("6b4a2e"), black = Color("1d1818")}
	var tori: Dictionary = common.duplicate()
	tori.merge(spec.colours.tori, true)
	var uke: Dictionary = common.duplicate()
	uke.merge(spec.colours.uke, true)
	d.colourways = [tori, uke]
	d.rest = spec.get("rest", {})
	if spec.has("hides_head_during"):
		d.hidden_during = {head = [[spec.hides_head_during, 1.0, 3.0]]}
	return d


static func _hair(parts: Array, style: String, hs: float) -> void:
	match style:
		"short":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s([Vector2(-12, -12), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(11, -24), Vector2(-4, -26), Vector2(-8, -14), Vector2(-14, -4)], hs), "hair", K.DECO))
		"tied":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s([Vector2(-12, -12), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(11, -24), Vector2(-4, -26), Vector2(-8, -14), Vector2(-14, -4)], hs), "hair", K.DECO))
			parts.append(P.new("tail_of_hair", "head", _s1(Vector2(-11, -24), hs), _s([Vector2(0, 0), Vector2(-6, 2), Vector2(-14, 30), Vector2(-8, 32), Vector2(-2, 8)], hs), "hair", K.DECO))
		"long":
			parts.append(P.new("hair", "head", Vector2.ZERO, _s([Vector2(-12, -10), Vector2(-11, -27), Vector2(-1, -33), Vector2(10, -29), Vector2(12, -20), Vector2(4, -26), Vector2(-6, -22), Vector2(-10, 6), Vector2(-14, 40), Vector2(-20, 38), Vector2(-16, 0)], hs), "hair", K.DECO))


static func _hat(parts: Array, hat: String, hs: float) -> void:
	var shape := []
	var slot := "black"
	match hat:
		"eboshi":
			shape = [Vector2(-9, -27), Vector2(7, -30), Vector2(12, -60), Vector2(-1, -62)]
		"tokin":
			shape = [Vector2(-5, -30), Vector2(6, -31), Vector2(4, -39), Vector2(-4, -39)]
		"kasa":
			shape = [Vector2(-26, -24), Vector2(26, -24), Vector2(4, -40), Vector2(-4, -40)]
			slot = "straw"
		"hood":
			shape = [Vector2(-13, -6), Vector2(-12, -28), Vector2(0, -35), Vector2(12, -30), Vector2(13, -22), Vector2(6, -28), Vector2(-6, -24), Vector2(-8, 0)]
			slot = "paper"
		"dish":
			shape = [Vector2(-10, -30), Vector2(10, -31), Vector2(8, -34), Vector2(-8, -34)]
			slot = "paper"
		_:
			return
	parts.append(P.new("hat", "head", Vector2.ZERO, _s(shape, hs), slot, K.DECO))


static func _appendages(parts: Array, spec: Dictionary, w: float) -> void:
	var tails: int = spec.get("tails", 0)
	var tail_shape := [Vector2(-4, 0), Vector2(4, 0), Vector2(10, 22), Vector2(8, 46), Vector2(0, 58), Vector2(-8, 46), Vector2(-10, 22)]
	if spec.get("tail", "fox") == "tanuki":
		tail_shape = [Vector2(-6, 0), Vector2(6, 0), Vector2(12, 20), Vector2(10, 40), Vector2(0, 48), Vector2(-10, 40), Vector2(-12, 20)]
	for i in tails:
		parts.append(P.new("tail_%d" % (i + 1), "hips", Vector2(-14 * w, 4), tail_shape, "extra", K.APPENDAGE))
	if spec.get("wings", false):
		var wing := [Vector2(0, 0), Vector2(10, 0), Vector2(30, 40), Vector2(26, 80), Vector2(10, 96), Vector2(-4, 70), Vector2(-6, 30)]
		parts.append(P.new("lead_wing", "torso", Vector2(-4, -48), wing, "extra", K.APPENDAGE))
		parts.append(P.new("trail_wing", "torso", Vector2(-8, -46), wing, "extra", K.APPENDAGE))
	var spider: int = spec.get("spider_legs", 0)
	for i in spider * 2:
		var name := "spider_%d" % (i + 1)
		parts.append(P.new(name, "torso", Vector2(-8, -40 + 3 * i), [Vector2(-3, 0), Vector2(3, 0), Vector2(2.5, 56), Vector2(-2.5, 56)], "extra", K.APPENDAGE))
		parts.append(P.new(name + "_foot", name, Vector2(0, 54), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(0.8, 66), Vector2(-0.8, 66)], "extra", K.DECO))
	if spec.get("shell", false):
		parts.append(P.new("shell", "torso", Vector2(-10 * w, -30), _sx([Vector2(-14, -22), Vector2(-2, -28), Vector2(6, -20), Vector2(8, 0), Vector2(6, 24), Vector2(-6, 30), Vector2(-16, 22), Vector2(-18, 0)], w), "extra", K.APPENDAGE))


## A held thing, on the given hand: its grip is the weapon part, the rest
## rides on it.
static func _item(d: PuppetDefinition, item: Dictionary) -> void:
	var hand: String = item.get("hand", "lead")
	var grip := hand + "_weapon"
	var at := hand + "_hand"
	var length: float = item.get("length", 0.0)
	match item.type:
		"blade", "nodachi":
			var l := length if length > 0.0 else (118.0 if item.type == "nodachi" else 80.0)
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -4), Vector2(2.5, -4), Vector2(2.5, 14), Vector2(-2, 14)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_guard", grip, Vector2(0, 14), [Vector2(-5, 0), Vector2(5, 0), Vector2(5, 3), Vector2(-5, 3)], "gear", K.DECO))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, 17), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, l - 6), Vector2(-1, l), Vector2(-2, 3)], "steel", K.DECO))
		"reverse_blade":
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -4), Vector2(2.5, -4), Vector2(2.5, 10), Vector2(-2, 10)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_blade", grip, Vector2(0, -4), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, -46), Vector2(-1, -50), Vector2(-2, -3)], "steel", K.DECO))
		"naginata", "staff":
			var shaft := length if length > 0.0 else 130.0
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, -36), Vector2(2, -36), Vector2(2, shaft - 36), Vector2(-2, shaft - 36)], "wood", K.WEAPON))
			if item.type == "naginata":
				d.parts.append(P.new(grip + "_blade", grip, Vector2(0, shaft - 36), [Vector2(-3, 0), Vector2(4, 0), Vector2(7, 28), Vector2(0, 38), Vector2(-3, 10)], "steel", K.DECO))
			else:
				d.parts.append(P.new(grip + "_rings", grip, Vector2(0, -36), [Vector2(0, 0), Vector2(8, -6), Vector2(10, -16), Vector2(0, -22), Vector2(-10, -16), Vector2(-8, -6)], "gear", K.DECO))
		"fan", "feather_fan":
			var slot := "extra" if item.type == "feather_fan" else "paper"
			d.parts.append(P.new(grip, at, Vector2(0, 5), [Vector2(-2, 0), Vector2(2, 0), Vector2(2, 6), Vector2(-2, 6)], "wood", K.WEAPON))
			d.parts.append(P.new(grip + "_leaf", grip, Vector2(0, 6), [Vector2(0, 0), Vector2(20, 18), Vector2(22, 30), Vector2(10, 38), Vector2(-10, 38), Vector2(-22, 30), Vector2(-20, 18)], slot, K.DECO))
		"ofuda":
			d.parts.append(P.new(grip, at, Vector2(0, 5), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 16), Vector2(-4, 16)], "paper", K.WEAPON))
		"lantern":
			d.parts.append(P.new(grip, at, Vector2(0, 5), [Vector2(-0.6, 0), Vector2(0.6, 0), Vector2(0.6, 12), Vector2(-0.6, 12)], "black", K.WEAPON))
			d.parts.append(P.new(grip + "_body", grip, Vector2(0, 12), [Vector2(-6, 0), Vector2(6, 0), Vector2(9, 8), Vector2(9, 18), Vector2(6, 26), Vector2(-6, 26), Vector2(-9, 18), Vector2(-9, 8)], "lantern", K.DECO))
		"flask":
			d.parts.append(P.new(grip, at, Vector2(0, 4), [Vector2(-2, 0), Vector2(2, 0), Vector2(3, 6), Vector2(-3, 6)], "gear", K.WEAPON))
			d.parts.append(P.new(grip + "_body", grip, Vector2(0, 6), [Vector2(-3, 0), Vector2(3, 0), Vector2(9, 12), Vector2(8, 22), Vector2(-8, 22), Vector2(-9, 12)], "gear", K.DECO))


static func _s(points: Array, k: float) -> Array:
	return points.map(func(p: Vector2) -> Vector2: return p * k)


static func _s1(p: Vector2, k: float) -> Vector2:
	return p * k


static func _sx(points: Array, k: float) -> Array:
	return points.map(func(p: Vector2) -> Vector2: return Vector2(p.x * k, p.y))
