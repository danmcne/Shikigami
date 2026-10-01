class_name Run
extends RefCounted
## One attempt at the campaign, as pure state: the chosen fighter, the spirits
## bound so far, and a sequence of random opponents in tiers.
##
## The first tier is short and drawn from the player's own kind, whose spirits
## cannot be bound; the second, longer tier is the other kind, where binding
## happens. A monster tier will follow once bosses exist. Opponents are
## shuffled within a tier and carry zero to two spirits of the kind they can
## bind. With both slots full, a newly bound spirit waits for the player to
## choose what to give up.
##
## The whole state round-trips through to_dict() / restore(), including the
## random generator, so a saved run resumes with the same opponents.

const SLOTS := 2
## Fights per tier: own kind, then the other kind.
const TIERS := [2, 4]
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


static func length() -> int:
	return TIERS.reduce(func(a: int, b: int) -> int: return a + b, 0)


func _init(chosen: FighterDefinition, all: Array[FighterDefinition], seed_value: int) -> void:
	character = chosen
	roster = all
	rng.seed = seed_value
	_draw_opponent()


## 0 for the own-kind tier, 1 for the other kind.
func tier() -> int:
	return 0 if fight < TIERS[0] else 1


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
	if fight >= length():
		return false
	_draw_opponent()
	return true


func to_dict() -> Dictionary:
	return {
		character = String(character.id), fight = fight, rng_seed = rng.seed, rng_state = rng.state,
		spirits = _ids(spirits), opponent = String(opponent.id), opponent_spirits = _ids(opponent_spirits),
	}


## A run restored from to_dict(), or null if it names fighters not in `all`.
static func restore(state: Dictionary, all: Array[FighterDefinition]) -> Run:
	var by_id := {}
	for d in all:
		by_id[d.id] = d
	var needed: Array = [state.get("character"), state.get("opponent")] \
			+ state.get("spirits", []) + state.get("opponent_spirits", [])
	for id in needed:
		if not by_id.has(StringName(str(id))):
			return null
	var run := Run.new(by_id[StringName(state.character)], all, state.rng_seed)
	run.fight = state.fight
	run.rng.state = state.rng_state
	run.opponent = by_id[StringName(state.opponent)]
	run.spirits.assign(state.spirits.map(func(id: Variant) -> FighterDefinition: return by_id[StringName(id)]))
	run.opponent_spirits.assign(state.opponent_spirits.map(
			func(id: Variant) -> FighterDefinition: return by_id[StringName(id)]))
	return run


func _draw_opponent() -> void:
	var own := tier() == 0
	var pool := roster.filter(func(d: FighterDefinition) -> bool: return (d.kind == character.kind) == own)
	opponent = pool[rng.randi() % pool.size()]
	var candidates: Array[FighterDefinition] = []
	candidates.assign(roster.filter(func(d: FighterDefinition) -> bool: return opponent.binds(d)))
	var count := mini(rng.rand_weighted(PackedFloat32Array(SPIRIT_COUNT_WEIGHTS)), candidates.size())
	opponent_spirits.clear()
	for k in count:
		var pick := candidates[rng.randi() % candidates.size()]
		candidates.erase(pick)
		opponent_spirits.append(pick)


static func _ids(defs: Array[FighterDefinition]) -> Array:
	return defs.map(func(d: FighterDefinition) -> String: return String(d.id))
