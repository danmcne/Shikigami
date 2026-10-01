class_name Run
extends RefCounted
## One attempt at the campaign, as pure state: the chosen fighter, the spirits
## bound so far, and a sequence of random opponents in tiers.
##
## The first tier is short and drawn from the player's own kind, whose spirits
## cannot be bound; the second, longer tier is the other kind, where binding
## happens. A monster tier will follow once bosses exist. Opponents are
## shuffled within a tier and carry zero to two spirits of the kind they can
## bind, each performing a random one of its two specials.
##
## Binding is two choices: which of the sealed fighter's specials its spirit
## will perform, then, if both slots are full, which slot to give up.
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
var spirits: Array[SpiritBinding] = []
## Zero-based index of the current fight.
var fight := 0
var opponent: FighterDefinition
var opponent_spirits: Array[SpiritBinding] = []
## A sealed fighter whose special is yet to be chosen, then the resulting
## binding if it still needs a slot.
var sealed: FighterDefinition = null
var pending: SpiritBinding = null
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


## The opponent's spirit was sealed; next, choose_special().
func seal(source: FighterDefinition) -> void:
	sealed = source


## Binds the sealed fighter performing special number `index`. Returns true
## if both slots are full and choose_slot() must follow.
func choose_special(index: int) -> bool:
	var binding := SpiritBinding.new(sealed, sealed.specials[index])
	sealed = null
	if spirits.size() < SLOTS:
		spirits.append(binding)
		return false
	pending = binding
	return true


## Puts the pending binding in `slot`, or releases it if slot is -1.
func choose_slot(slot: int) -> void:
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
		spirits = _pairs(spirits), opponent = String(opponent.id), opponent_spirits = _pairs(opponent_spirits),
	}


## A run restored from to_dict(), or null if it is empty or names fighters or
## specials that no longer exist.
static func restore(state: Dictionary, all: Array[FighterDefinition]) -> Run:
	if state.is_empty():
		return null
	var by_id := {}
	for d in all:
		by_id[String(d.id)] = d
	if not (by_id.has(str(state.get("character"))) and by_id.has(str(state.get("opponent")))):
		return null
	var run := Run.new(by_id[state.character], all, state.rng_seed)
	run.fight = state.fight
	run.rng.state = state.rng_state
	run.opponent = by_id[state.opponent]
	for field in ["spirits", "opponent_spirits"]:
		var bindings: Array[SpiritBinding] = []
		for pair in state.get(field, []):
			var source: FighterDefinition = by_id.get(str(pair[0]))
			if source == null or not StringName(pair[1]) in source.specials:
				return null
			bindings.append(SpiritBinding.new(source, StringName(pair[1])))
		run.set(field, bindings)
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
		opponent_spirits.append(SpiritBinding.new(pick, pick.specials[rng.randi() % pick.specials.size()]))


static func _pairs(bindings: Array[SpiritBinding]) -> Array:
	return bindings.map(func(b: SpiritBinding) -> Array: return [String(b.source.id), String(b.move)])
