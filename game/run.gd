class_name Run
extends RefCounted
## One attempt at the campaign, as pure state: the chosen fighter, the spirits
## bound so far, and a sequence of random opponents. Tiers come later, when
## there is a roster to tier.
##
## Opponents carry zero to two spirits of the kind they can bind. Beating an
## opponent the player can bind, and landing the finisher, binds its spirit;
## with both slots full the player chooses what to give up.

const LENGTH := 6
const SLOTS := 2
## Chances of an opponent carrying 0, 1 or 2 spirits.
const SPIRIT_COUNT_WEIGHTS := [0.4, 0.4, 0.2]

var character: FighterDefinition
var roster: Array[FighterDefinition]
var spirits: Array[FighterDefinition] = []
## Zero-based index of the current fight.
var fight := 0
var opponent: FighterDefinition
var opponent_spirits: Array[FighterDefinition] = []
## A newly bound spirit waiting for a free slot.
var pending: FighterDefinition = null
var rng := RandomNumberGenerator.new()


func _init(chosen: FighterDefinition, all: Array[FighterDefinition], seed_value: int) -> void:
	character = chosen
	roster = all
	rng.seed = seed_value
	_draw_opponent()


## Records a won fight. Returns true if the bound spirit needs a slot choice.
func win(bound: FighterDefinition) -> bool:
	if bound == null:
		return false
	if spirits.size() < SLOTS:
		spirits.append(bound)
		return false
	pending = bound
	return true


## Puts the pending spirit in `slot`, or releases it if slot is -1.
func choose(slot: int) -> void:
	if slot >= 0:
		spirits[slot] = pending
	pending = null


## Moves to the next fight. Returns false when the run is complete.
func advance() -> bool:
	fight += 1
	if fight >= LENGTH:
		return false
	_draw_opponent()
	return true


func _draw_opponent() -> void:
	opponent = roster[rng.randi() % roster.size()]
	var candidates: Array[FighterDefinition] = []
	candidates.assign(roster.filter(func(d: FighterDefinition) -> bool: return opponent.binds(d)))
	var count := mini(rng.rand_weighted(PackedFloat32Array(SPIRIT_COUNT_WEIGHTS)), candidates.size())
	opponent_spirits.clear()
	for k in count:
		var pick := candidates[rng.randi() % candidates.size()]
		candidates.erase(pick)
		opponent_spirits.append(pick)
