class_name PuppetDefinition
extends RefCounted
## A fighter's look as a cut-paper puppet: flat parts joined at pivots, two
## colourways, and two faces. Purely visual: the fighter's boxes stay the
## truth, and the puppet is scaled to its standing hurtbox.
##
## Coordinates are puppet units: feet at y = 0, up is -y, forward is +x, and a
## puppet stands about `height` tall. Limbs are drawn hanging down from their
## pivot and the torso standing up from the hips, so a pose of all zeros is a
## figure standing straight with arms at its sides.


class Part:
	var name: String
	var parent: String
	## Where this part joins its parent, in the parent's space.
	var pivot: Vector2
	var shape: PackedVector2Array
	## Colour slot, looked up in the colourway.
	var slot: String
	## Draw order: lower first. Far-side limbs sit behind the body.
	var z: int
	## Far-side parts are drawn a little darker.
	var far := false

	func _init(part_name: String, parent_name: String, at: Vector2, points: Array, colour_slot: String,
			order: int, is_far := false) -> void:
		name = part_name
		parent = parent_name
		pivot = at
		shape = PackedVector2Array(points)
		slot = colour_slot
		z = order
		far = is_far


var parts: Array = []
## [tori, uke]: colour slot -> Color. Tori is player 1's and the computer's in
## the campaign; uke is player 2's in versus.
var colourways: Array = []
## Face details drawn on the head: [points, slot] pairs. Teru (the mask
## tilted up, bright) for advancing and attacking; kumoru (tilted down,
## clouded) for guarding, being hit and defeat.
var face_teru: Array = []
var face_kumoru: Array = []
var height := 170.0
## This puppet's resting angles (how it holds its weapon at rest), over the
## shared defaults; states that move a joint override them.
var rest: Dictionary = {}

## Weapons and striking limbs: a segment on a bone, with a width, divided
## into zones that wound at different strengths (the tip most). These are
## gameplay data: a move's hitboxes are traced from them.
##   {name, bone, from: Vector2, to: Vector2, width, zones: [[from, to, damage scale], ...]}
var weapons: Array = []
## Moves animated as swings, by move id:
##   {keys = [[t, {joint: angle}], ...], strikes = [weapon names], base = "stand" | "crouch" | "air"}
## t runs 0..1 through start-up, 1..2 through the active frames, 2..3
## through recovery, so a swing fits any frame data.
var swings: Dictionary = {}
## Parts drawn only during certain moves (a sake gourd in the hand), and
## parts hidden during certain moves (the same gourd at the hip): part name
## -> move ids.
var props: Dictionary = {}
var hidden_during: Dictionary = {}

const DEFAULTS := {
	torso = 4.0, head = -2.0,
	upper_arm_f = -35.0, lower_arm_f = -55.0, weapon_f = 0.0,
	upper_arm_b = 25.0, lower_arm_b = -40.0, weapon_b = 0.0,
	thigh_f = -14.0, shin_f = 12.0, thigh_b = 16.0, shin_b = 4.0,
}
const CROUCH := {torso = 22.0, thigh_f = -78.0, shin_f = 100.0, thigh_b = -40.0, shin_b = 110.0}
const CROUCH_DROP := 38.0
const AIR := {thigh_f = -60.0, shin_f = 80.0, thigh_b = -25.0, shin_b = 70.0}


## The resting angles for a context: standing, crouching or in the air.
func base_angles(context: String) -> Dictionary:
	var a := DEFAULTS.duplicate()
	a.merge(rest, true)
	if context == "crouch":
		a.merge(CROUCH, true)
	elif context == "air":
		a.merge(AIR, true)
	return a


## Where move `m` (animated by `swing`) has the puppet at `frame`: joint
## angles and the root's drop, interpolated between the swing's keys.
func swing_pose(swing: Dictionary, m: MoveDefinition, frame: int) -> Dictionary:
	var context: String = swing.get("base", "stand")
	var a := base_angles(context)
	var t := _phase(m, frame)
	var keys: Array = [[0.0, {}]] + swing.keys + [[3.0, {}]]
	var k := 0
	while k < keys.size() - 2 and keys[k + 1][0] <= t:
		k += 1
	var t0: float = keys[k][0]
	var t1: float = keys[k + 1][0]
	var w := 0.0 if is_equal_approx(t1, t0) else clampf((t - t0) / (t1 - t0), 0.0, 1.0)
	var rest_a := a.duplicate()
	for joint in rest_a:
		var v0: float = keys[k][1].get(joint, rest_a[joint])
		var v1: float = keys[k + 1][1].get(joint, rest_a[joint])
		a[joint] = lerpf(v0, v1, w)
	return {angles = a, root = Vector2(0, CROUCH_DROP if context == "crouch" else 0.0), root_rot = 0.0}


## Each part's transform in puppet space for a set of angles.
func pose_transforms(angles: Dictionary, root := Vector2.ZERO, root_rot := 0.0) -> Dictionary:
	var out := {}
	var top := Transform2D(deg_to_rad(root_rot), root)
	for part in parts:
		_place(part, angles, out, top)
	return out


## Where the move's striking weapons are at `frame`: boxes in the fighter's
## local space (scaled by `scale`), each with the damage scale of its zone.
## A zone that does not wound leaves no box.
func weapon_strikes(swing: Dictionary, m: MoveDefinition, frame: int, scale: float) -> Array:
	var pose := swing_pose(swing, m, frame)
	var transforms := pose_transforms(pose.angles, pose.root, pose.root_rot)
	var out: Array = []
	for w in weapons:
		if not w.name in swing.get("strikes", []):
			continue
		var t: Transform2D = transforms[w.bone]
		var a: Vector2 = t * w.from
		var b: Vector2 = t * w.to
		for zone in w.zones:
			if zone[2] <= 0.0:
				continue
			var p0 := a.lerp(b, zone[0])
			var p1 := a.lerp(b, zone[1])
			var pieces := maxi(1, ceili(p0.distance_to(p1) / 14.0))
			for i in pieces:
				var q0 := p0.lerp(p1, float(i) / pieces)
				var q1 := p0.lerp(p1, float(i + 1) / pieces)
				var box := Rect2(q0, Vector2.ZERO).expand(q1).grow(w.width / 2.0)
				out.append([Rect2(box.position * scale, box.size * scale), zone[2]])
	return out


func _place(part: Part, angles: Dictionary, out: Dictionary, top: Transform2D) -> Transform2D:
	if out.has(part.name):
		return out[part.name]
	var own := Transform2D(deg_to_rad(angles.get(part.name, 0.0)), part.pivot)
	var t := top * own
	if part.parent != "":
		for other in parts:
			if other.name == part.parent:
				t = _place(other, angles, out, top) * own
	out[part.name] = t
	return t


## 0..1 start-up, 1..2 active, 2..3 recovery.
static func _phase(m: MoveDefinition, frame: int) -> float:
	if frame < m.startup:
		return float(frame) / maxf(m.startup, 1.0)
	if frame < m.startup + m.active:
		return 1.0 + float(frame - m.startup) / maxf(m.active, 1.0)
	return 2.0 + minf(float(frame - m.startup - m.active) / maxf(m.recovery, 1.0), 1.0)
