class_name PuppetDefinition
extends RefCounted
## A fighter's cut-paper puppet on the shared humanoid rig.
##
## One skeleton, fixed bone lengths, two limbs of each kind. Poses name limbs
## by their fighting role: "lead" (the side toward the opponent) and "trail".
## A view then decides, for each side, where its shoulder and hip attach,
## whether it is near or far from the viewer, which shape variants are drawn,
## and the order of the layers:
##
##   SIDE      profile. Shoulders almost together; the lead side is near or far
##             as the character chooses. Back to front: far arm and far leg;
##             torso, head, near leg; clothing over torso and legs; near arm.
##   FRONT     chest to the viewer; shoulders at the torso's edges, neither
##             side nearer. Back to front: torso and legs; head and clothing;
##             upper arms; forearms; hands and weapons.
##   DIAGONAL  the composite (aspective) view of Egyptian figures: torso and
##             arms as in front view, head and legs in profile. Turning a
##             profile's chest toward the viewer swings the lead side away, so
##             the lead side is far and the trailing side near. Back to front:
##             torso and lead leg; trailing leg; head and clothing; upper arms;
##             forearms; hands and weapons (far before near within each).
##
## Appendages that grow from the back or hips (tails, wings, a spider's legs,
## a kappa's shell) are drawn behind everything else in every view.
##
## Depth, never lead or trail, decides shading: far parts are darkened.
## Nothing ever changes layer to be seen: a weapon behind the torso stays
## behind it, so weapons on the far side are large or held up and out.
##
## Coordinates are puppet units: feet at y = 0, up is -y, forward (toward the
## opponent) is +x. Limbs hang down from their pivot at angle 0 and the torso
## stands up from the hips; a negative angle swings a hanging limb forward.

enum View { SIDE, FRONT, DIAGONAL }
## What a part is, which decides its layer. A DECO rides on its parent, drawn
## just after it in the same layer and at the same depth (pleats on a leg,
## rings on an arm, horns on a head, a blade on its hilt).
enum Kind { BODY, HEAD, LEG, CLOTHING, ARM_UPPER, ARM_FORE, HAND, WEAPON, DECO, APPENDAGE }

const VIEW_NAMES := {View.SIDE: "side", View.FRONT: "front", View.DIAGONAL: "diagonal"}
enum Depth { FAR, MID, NEAR }


class Part:
	var name: String
	var parent: String
	## Where this part joins its parent: a fixed point, or the name of a view
	## anchor (lead_shoulder, trail_shoulder, lead_hip, trail_hip, neck).
	var pivot := Vector2.ZERO
	var anchor := ""
	## Its outline, per view name ("side", "front", "diagonal") or "any".
	var shapes: Dictionary = {}
	var slot: String
	var kind: int
	## "lead", "trail" or "" (from the name's prefix, or the parent's for a deco).
	var side := ""
	## Hangs straight down whatever its parent does (a lantern on its stick).
	var hangs := false
	## Cloth that reaches the floor rests on it: drawn compressed about its
	## joint rather than through the floor.
	var rests_on_floor := false
	## A skirt built each frame around the legs: "ankle" (covering them to
	## just above the feet) or "knee". Its outline wraps the waist and both
	## legs' knees (and ankles), padded outward, whatever the legs do.
	var wraps := ""

	func _init(part_name: String, parent_name: String, at: Variant, outline: Variant, colour_slot: String,
			part_kind: int) -> void:
		name = part_name
		parent = parent_name
		if at is String:
			anchor = at
		else:
			pivot = at
		shapes = outline if outline is Dictionary else {"any": outline}
		slot = colour_slot
		kind = part_kind
		if part_name.begins_with("lead_"):
			side = "lead"
		elif part_name.begins_with("trail_"):
			side = "trail"


var parts: Array = []
## [tori, uke]: colour slot -> Color.
var colourways: Array = []
## Face details drawn on the head, in profile: [points, slot] pairs. Teru (the
## mask tilted up, bright) for advancing and attacking; kumoru (tilted down,
## clouded) for guarding, being hit and defeat.
var face_teru: Array = []
var face_kumoru: Array = []
var height := 170.0
## The view this character is drawn in, and in side view whether its lead
## side is the near one.
var view := View.SIDE
var side_lead_near := true
## Per view: where the limbs attach. {view: {lead_shoulder, trail_shoulder,
## lead_hip, trail_hip, neck}}
var anchors: Dictionary = {}
## Named points on parts, for limbs to reach: {name: [part, point]}.
var points: Dictionary = {}
## Resting angles over the shared defaults.
var rest: Dictionary = {}
## Weapons and striking limbs, which are gameplay data: a move's hitboxes are
## traced from them.
##   {name, bone, from: Vector2, to: Vector2, width, zones: [[from, to, damage scale], ...]}
var weapons: Array = []
## Moves animated as swings, by move id:
##   {keys = [[t, {joint: angle, ik = {lead|trail: {to = point, bend = ±1}}}], ...],
##    strikes = [weapon names], base = "stand" | "crouch" | "air"}
## t runs 0..1 through start-up, 1..2 through the active frames, 2..3
## through recovery.
var swings: Dictionary = {}
## Parts drawn only during certain moves, and parts hidden during certain
## moves: part name -> entries, each a move id (the whole move) or
## [move id, from t, to t] (part of it, in the phase units of swings). Hiding
## a part hides everything attached to it.
var props: Dictionary = {}
var hidden_during: Dictionary = {}
## The arm that strikes in moves without a swing of their own (the one
## holding the weapon).
var attack_arm := "lead"
## Two-handed holds: the other hand grips a segment of a held part and may
## slide along it. {side: {part, from: Vector2, to: Vector2}}. A swing key
## may release it: release = ["trail"].
var grips: Dictionary = {}
## Joint limits in degrees, as [least, most] of the joint's angle relative
## to its parent: elbows bend only forward, knees only backward. A puppet
## whose legs are not human legs may clear them.
var limits: Dictionary = {fore = [-160.0, 0.0], shin = [0.0, 160.0]}
## "stride" walks with legs passing each other (in profile); "shuffle" keeps
## the stance, as in the diagonal view or on legs that are not human.
var gait := "stride"
## A puppet's own crouch and jump leg poses, over the shared ones.
var crouch_pose: Dictionary = {}
var air_pose: Dictionary = {}
## Clothing that moves with the legs: part -> {joints, lead}. Its angle is
## the forward-most of the joints' angles weighted by `lead` with the rest
## (a skirt's upper piece swinging with the thighs, its lower piece bending
## at the knee with the shins).
var follows: Dictionary = {}

const DEFAULTS := {
	torso = 4.0, head = -2.0,
	lead_upper = -35.0, lead_fore = -55.0, lead_weapon = 0.0,
	trail_upper = 25.0, trail_fore = -40.0, trail_weapon = 0.0,
	lead_thigh = -14.0, lead_shin = 12.0, trail_thigh = 16.0, trail_shin = 4.0,
}
const CROUCH := {torso = 22.0, lead_thigh = -78.0, lead_shin = 100.0, trail_thigh = -40.0, trail_shin = 110.0}
const CROUCH_DROP := 38.0
const AIR := {lead_thigh = -60.0, lead_shin = 80.0, trail_thigh = -25.0, trail_shin = 70.0}

# Layer group of each kind at each depth, per view.
const _SIDE_GROUPS := {
	Depth.FAR: {Kind.ARM_UPPER: 0, Kind.ARM_FORE: 0, Kind.HAND: 0, Kind.WEAPON: 0, Kind.LEG: 0},
	Depth.MID: {Kind.BODY: 1, Kind.HEAD: 1, Kind.CLOTHING: 2},
	Depth.NEAR: {Kind.LEG: 1, Kind.ARM_UPPER: 3, Kind.ARM_FORE: 3, Kind.HAND: 3, Kind.WEAPON: 3},
}
const _FRONT_GROUPS := {Kind.BODY: 0, Kind.LEG: 0, Kind.HEAD: 1, Kind.CLOTHING: 1,
		Kind.ARM_UPPER: 2, Kind.ARM_FORE: 3, Kind.HAND: 4, Kind.WEAPON: 4}
const _DIAGONAL_GROUPS := {Kind.BODY: 0, Kind.HEAD: 2, Kind.CLOTHING: 2,
		Kind.ARM_UPPER: 3, Kind.ARM_FORE: 4, Kind.HAND: 5, Kind.WEAPON: 5}


## Near, far or neither, for a side in a view.
func depth_of(side: String, v: int) -> int:
	if side == "":
		return Depth.MID
	match v:
		View.SIDE:
			var lead_near := side_lead_near
			return Depth.NEAR if (side == "lead") == lead_near else Depth.FAR
		View.DIAGONAL:
			return Depth.FAR if side == "lead" else Depth.NEAR
	return Depth.MID


## How much a part is darkened for depth in a view: far parts in profile;
## only the far leg in the diagonal view, whose arms are drawn as in front.
func shade_of(part: Part, v: int) -> float:
	var base := _base_of(part)
	if depth_of(base.side, v) != Depth.FAR:
		return 0.0
	if v == View.SIDE:
		return 0.25
	if v == View.DIAGONAL and base.kind == Kind.LEG:
		return 0.15
	return 0.0


## The parts in the order they are drawn in a view, back to front.
func draw_order(v: int) -> Array:
	var keyed: Array = []
	for i in parts.size():
		keyed.append([_layer_key(parts[i], v), i, parts[i]])
	keyed.sort_custom(func(a: Array, b: Array) -> bool:
		for k in 3:
			if a[0][k] != b[0][k]:
				return a[0][k] < b[0][k]
		return a[1] < b[1])
	return keyed.map(func(e: Array) -> Part: return e[2])


## [layer group, depth rank, order of declaration of the base part]: decos
## take their base part's key, so they follow it.
func _layer_key(part: Part, v: int) -> Array:
	var base := _base_of(part)
	var depth := depth_of(base.side, v)
	if base.kind == Kind.APPENDAGE:
		return [-1, depth, parts.find(base)]
	var group := 0
	match v:
		View.SIDE:
			var at_depth: Dictionary = _SIDE_GROUPS[depth]
			group = at_depth.get(base.kind, _SIDE_GROUPS[Depth.MID].get(base.kind, 1))
		View.FRONT:
			group = _FRONT_GROUPS.get(base.kind, 1)
		View.DIAGONAL:
			if base.kind == Kind.LEG:
				group = 0 if depth == Depth.FAR else 1
			else:
				group = _DIAGONAL_GROUPS.get(base.kind, 2)
	return [group, depth, parts.find(base)]


func _base_of(part: Part) -> Part:
	var p := part
	while p.kind == Kind.DECO and p.parent != "":
		p = find(p.parent)
	return p


func find(part_name: String) -> Part:
	for p in parts:
		if p.name == part_name:
			return p
	return null


## The outline drawn for a part in a view. The diagonal view takes torso and
## clothing from the front view and head and limbs from the side view.
func shape_of(part: Part, v: int) -> PackedVector2Array:
	var base := _base_of(part)
	var order: Array = [VIEW_NAMES[v]]
	if v == View.DIAGONAL:
		order.append("front" if base.kind in [Kind.BODY, Kind.CLOTHING] else "side")
	order.append("any")
	for key in order:
		if part.shapes.has(key):
			return part.shapes[key]
	return part.shapes.values()[0]


## The outline drawn for a part in its pose: a skirt's built around the
## legs, anything else its shape. In the part's own space.
func outline_of(part: Part, transforms: Dictionary) -> PackedVector2Array:
	if part.wraps == "":
		return shape_of(part, view)
	var waist: Transform2D = transforms["hips"]
	var pad := 9.0
	var points := PackedVector2Array([waist * Vector2(-19, -4), waist * Vector2(19, -4)])
	for side in ["lead", "trail"]:
		var knee: Vector2 = transforms[side + "_shin"].origin
		points.append(knee + Vector2(pad, 0))
		points.append(knee + Vector2(-pad, 0))
		if part.wraps == "ankle":
			var ankle: Vector2 = transforms[side + "_foot"].origin
			points.append(ankle + Vector2(pad * 1.6, -3))
			points.append(ankle + Vector2(-pad * 1.6, -3))
		else:
			points.append(knee + Vector2(pad, 10))
			points.append(knee + Vector2(-pad, 10))
	var hull := Geometry2D.convex_hull(points)
	hull.resize(hull.size() - 1)
	var inverse := (transforms[part.name] as Transform2D).affine_inverse()
	for k in hull.size():
		hull[k] = inverse * hull[k]
	return hull


## Where a part joins its parent in a view.
func pivot_of(part: Part, v: int) -> Vector2:
	if part.anchor == "":
		return part.pivot
	var at: Dictionary = anchors.get(v, anchors.get(view, {}))
	return at.get(part.anchor, Vector2.ZERO)


## The resting angles for a context: standing, crouching or in the air.
func base_angles(context: String) -> Dictionary:
	var a := DEFAULTS.duplicate()
	for joint in rest:
		if rest[joint] is float or rest[joint] is int:
			a[joint] = float(rest[joint])
	if context == "crouch":
		a.merge(CROUCH, true)
		a.merge(crouch_pose, true)
	elif context == "air":
		a.merge(AIR, true)
		a.merge(air_pose, true)
	limit(a)
	# A guard may be described by where a hand is and where a weapon points.
	resolve(a, rest, Vector2(0, CROUCH_DROP if context == "crouch" else 0.0))
	return a


## Applies a pose's reaches and aims, in that order: ik = {side: {to, bend}}
## puts a hand on a point; aim = {part: angle} points a part (a weapon) at an
## absolute angle, whatever the arm holding it is doing.
func resolve(a: Dictionary, pose: Dictionary, root := Vector2.ZERO) -> void:
	var reaches: Dictionary = pose.get("ik", {})
	for side in reaches:
		var reach: Dictionary = reaches[side]
		reach_with(a, side, reach.to, reach.get("bend", -1.0), root)
	var aims: Dictionary = pose.get("aim", {})
	for part_name in aims:
		var above := 0.0
		var q := find(part_name)
		while q != null and q.parent != "":
			q = find(q.parent)
			above += a.get(q.name, 0.0)
		a[part_name] = aims[part_name] - above


## Swings clothing with the legs it covers.
func apply_follows(a: Dictionary) -> void:
	for part_name in follows:
		var f: Dictionary = follows[part_name]
		var values: Array = f.joints.map(func(j: String) -> float: return a.get(j, 0.0))
		var lead: float = values.min() if f.get("forward_is_less", true) else values.max()
		var mean: float = values.reduce(func(s: float, v: float) -> float: return s + v, 0.0) / values.size()
		a[part_name] = lerpf(mean, lead, f.get("lead", 0.7)) * f.get("scale", 1.0)


## Keeps every elbow and knee within its limits.
func limit(a: Dictionary) -> Dictionary:
	for side in ["lead", "trail"]:
		for joint in limits:
			var key: String = side + "_" + joint
			if a.has(key):
				a[key] = clampf(a[key], limits[joint][0], limits[joint][1])
	return a


## The free hand: one that neither holds a weapon nor grips one. Light
## attacks are thrown with it; anything else with the weapon arm.
func striking_arm(m: MoveDefinition) -> String:
	if String(m.id).contains("light"):
		for side in ["lead", "trail"]:
			if find(side + "_weapon") == null and not grips.has(side):
				return side
	return attack_arm


## Where move `m` (animated by `swing`) has the puppet at `frame`: joint
## angles and the root's drop, interpolated between the swing's keys, each
## key's reaches solved first.
func swing_pose(swing: Dictionary, m: MoveDefinition, frame: int) -> Dictionary:
	var context: String = swing.get("base", "stand")
	var base := base_angles(context)
	var root := Vector2(0, CROUCH_DROP if context == "crouch" else 0.0)
	var t := _phase(m, frame)
	var keys: Array = [[0.0, {}]] + swing.keys + [[3.0, {}]]
	var k := 0
	while k < keys.size() - 2 and keys[k + 1][0] <= t:
		k += 1
	var t0: float = keys[k][0]
	var t1: float = keys[k + 1][0]
	var w := 0.0 if is_equal_approx(t1, t0) else clampf((t - t0) / (t1 - t0), 0.0, 1.0)
	var a0 := _key_angles(base, keys[k][1], root)
	var a1 := _key_angles(base, keys[k + 1][1], root)
	var a := a0.duplicate()
	for joint in a1:
		a[joint] = lerpf(a0.get(joint, a1[joint]), a1[joint], w)
	limit(a)
	apply_grips(a, root, keys[k][1].get("release", []))
	apply_follows(a)
	return {angles = a, root = root, root_rot = 0.0}


## Puts each gripping hand on its grip: on the point of the grip, sliding
## along it, at which its arm is comfortably bent.
func apply_grips(a: Dictionary, root := Vector2.ZERO, released: Array = []) -> void:
	for side in grips:
		if side in released or find(side + "_upper") == null:
			continue
		var g: Dictionary = grips[side]
		var placed := pose_transforms(a, root)
		var t: Transform2D = placed[g.part]
		var shoulder: Vector2 = placed[side + "_upper"].origin
		var full := find(side + "_fore").pivot.length() + _wrist(side).length()
		var best := Vector2.INF
		var best_gap := INF
		for i in 9:
			var q: Vector2 = t * (g.from as Vector2).lerp(g.to, i / 8.0)
			var gap := absf(q.distance_to(shoulder) - 0.85 * full)
			if gap < best_gap:
				best_gap = gap
				best = q
		reach_with(a, side, best, -1.0, root)


## A key's full angles: the base, the key's own angles, then its reaches.
func _key_angles(base: Dictionary, key: Dictionary, root: Vector2) -> Dictionary:
	var a := base.duplicate()
	for joint in key:
		if key[joint] is float or key[joint] is int:
			a[joint] = float(key[joint])
	resolve(a, key, root)
	return a


## Bends `side`'s arm so its hand reaches the named point (or a point in
## puppet space), elbow bending the way `bend` says. Fixed bone lengths: a
## point out of reach is reached toward, never stretched to.
func reach_with(a: Dictionary, side: String, target: Variant, bend: float, root := Vector2.ZERO) -> void:
	var upper := find(side + "_upper")
	var fore := find(side + "_fore")
	if upper == null or fore == null:
		return
	var placed := pose_transforms(a, root)
	var goal: Vector2 = target if target is Vector2 else placed[points[target][0]] * points[target][1]
	var shoulder: Vector2 = placed[upper.name].origin
	var parent_angle: float = (placed[upper.parent] as Transform2D).get_rotation()
	var wrist_local := _wrist(side)
	var l1 := fore.pivot.length()
	var l2 := wrist_local.length()
	var to_goal := goal - shoulder
	var d := clampf(to_goal.length(), absf(l1 - l2) + 0.01, l1 + l2 - 0.01)
	var cos_a := clampf((l1 * l1 + d * d - l2 * l2) / (2.0 * l1 * d), -1.0, 1.0)
	var toward := _hanging(to_goal)
	# Of the two ways the elbow could bend, take the one the joint allows
	# (preferring `bend` when both do).
	var best: Array = []
	for way in [bend, -bend]:
		var upper_abs: float = toward + way * acos(cos_a)
		var elbow := shoulder + Vector2(-sin(upper_abs), cos(upper_abs)) * l1
		var fore_abs := _hanging(goal - elbow)
		# Bones whose child pivot is slightly off their axis.
		upper_abs -= _hanging(fore.pivot)
		fore_abs -= _hanging(wrist_local)
		var upper_deg := rad_to_deg(upper_abs - parent_angle)
		var fore_deg := wrapf(rad_to_deg(fore_abs - upper_abs), -180.0, 180.0)
		var allowed: bool = not limits.has("fore") or (fore_deg >= limits.fore[0] - 0.5 and fore_deg <= limits.fore[1] + 0.5)
		if best.is_empty() or (allowed and not best[2]):
			best = [upper_deg, fore_deg, allowed]
	# The same direction written nearest the arm's angle before, so that
	# moving between poses takes the short way round, not behind the back.
	var before: float = a.get(upper.name, 0.0)
	a[upper.name] = before + wrapf(best[0] - before, -180.0, 180.0)
	a[fore.name] = best[1]
	limit(a)


## Where the hand is on the forearm: the pivot of the hand, or of whatever the
## forearm holds.
func _wrist(side: String) -> Vector2:
	for p in parts:
		if p.parent == side + "_fore" and (p.kind == Kind.HAND or p.kind == Kind.WEAPON):
			return p.pivot
	return Vector2(0, 24)


## The angle at which a limb hanging along +y points along `v`.
static func _hanging(v: Vector2) -> float:
	return atan2(-v.x, v.y)


## Each part's transform in puppet space for a set of angles, in this
## character's view.
func pose_transforms(angles: Dictionary, root := Vector2.ZERO, root_rot := 0.0) -> Dictionary:
	var out := {}
	var top := Transform2D(deg_to_rad(root_rot), root)
	for part in parts:
		_place(part, angles, out, top)
	return out


## Where the move's striking weapons are at `frame`: boxes in the fighter's
## local space (scaled by `scale`), each with the damage scale of its zone.
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
		# A swing may wound with only part of the weapon (the Drying Pole's tip).
		for zone in swing.get("zones", w.zones):
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
	var own := Transform2D(deg_to_rad(angles.get(part.name, 0.0)), pivot_of(part, view))
	var t := top * own
	if part.parent != "":
		t = _place(find(part.parent), angles, out, top) * own
	if part.hangs:
		# Straight down, whatever holds it.
		t = Transform2D(top.get_rotation(), t.origin)
	if part.rests_on_floor:
		var lowest := -INF
		for q in shape_of(part, view):
			lowest = maxf(lowest, (t * q).y)
		var floor_y := 0.0
		if lowest > floor_y and lowest > t.origin.y + 1.0:
			var k := (floor_y - t.origin.y) / (lowest - t.origin.y)
			t = Transform2D(Vector2(1, 0), Vector2(0, k), Vector2(0, t.origin.y * (1.0 - k))) * t
	out[part.name] = t
	return t


## Whether a part is drawn during `move` at `frame` (no move: at rest).
func shows(part: Part, move: MoveDefinition, frame: int) -> bool:
	var p := part
	while p != null:
		if props.has(p.name) and not _during(props[p.name], move, frame):
			return false
		if hidden_during.has(p.name) and _during(hidden_during[p.name], move, frame):
			return false
		p = find(p.parent) if p.parent != "" else null
	return true


func _during(entries: Array, move: MoveDefinition, frame: int) -> bool:
	if move == null:
		return false
	for e in entries:
		if e is Array:
			if e[0] == move.id:
				var t := _phase(move, frame)
				if t >= e[1] and t < e[2]:
					return true
		elif e == move.id:
			return true
	return false


## 0..1 start-up, 1..2 active, 2..3 recovery.
static func _phase(m: MoveDefinition, frame: int) -> float:
	if frame < m.startup:
		return float(frame) / maxf(m.startup, 1.0)
	if frame < m.startup + m.active:
		return 1.0 + float(frame - m.startup) / maxf(m.active, 1.0)
	return 2.0 + minf(float(frame - m.startup - m.active) / maxf(m.recovery, 1.0), 1.0)
