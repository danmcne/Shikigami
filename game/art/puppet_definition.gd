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
