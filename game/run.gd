class_name Run
extends RefCounted
## One attempt at the campaign, as pure state: the chosen fighter, the spirits
## bound so far, and a sequence of random opponents in tiers.
##
## Two tiers of four: first the player's own kind, then the other kind (a
## monster tier will follow). Within each tier the opponents carry 0, 1, 2 and
## 2 spirits, of the kind they can bind:
##
##   own-kind tier    the second opponent's single spirit is granted on
##                    victory; from the third and fourth, the finisher
##                    captures one of the spirits they carry. Their own
##                    powers, being the player's kind, can't be taken.
##   other-kind tier  the finisher seals the opponent itself, and the player
##                    takes one of its two specials.
##
## Every capture is a choice from an offer (or a release), then, if both
## slots are full, which slot to give up.
##
## The state round-trips through to_dict() / restore(), including the random
## generator, so a saved run resumes with the same opponents.

const SLOTS := 2
const FIGHTS_PER_TIER := 4
const TIERS := 2
## Spirits carried by the opponents of each tier, in order.
const CARRIED := [0, 1, 2, 2]
## In the own-kind tier, the fight whose single spirit is simply granted.
const GRANTED_AT := 1

var character: FighterDefinition
var roster: Array[FighterDefinition]
var spirits: Array[SpiritBinding] = []
## Zero-based index of the current fight.
var fight := 0
var opponent: FighterDefinition
var opponent_spirits: Array[SpiritBinding] = []
## Bindings on offer after a capture, and a chosen binding waiting for a slot.
var offer: Array[SpiritBinding] = []
var pending: SpiritBinding = null
var rng := RandomNumberGenerator.new()


static func length() -> int:
	return FIGHTS_PER_TIER * TIERS


func _init(chosen: FighterDefinition, all: Array[FighterDefinition], seed_value: int) -> void:
	character = chosen
	roster = all
	rng.seed = seed_value
	_draw_opponent()


## 0 for the own-kind tier, 1 for the other kind.
func tier() -> int:
	return floori(float(fight) / FIGHTS_PER_TIER)


func place_in_tier() -> int:
	return fight % FIGHTS_PER_TIER


## Whether this fight's spirit is granted on victory, with no finisher.
func grants_on_victory() -> bool:
	return tier() == 0 and place_in_tier() == GRANTED_AT


## Called after a won fight. `sealed` says whether the finisher connected.
## Fills `offer`; returns true if there is a choice to make.
func after_victory(sealed: bool) -> bool:
	offer.clear()
	if grants_on_victory():
		for b in opponent_spirits:
			_take(b)
		return pending != null
	if not sealed:
		return false
	if character.binds(opponent):
		for special in opponent.specials:
			offer.append(SpiritBinding.new(opponent, special))
	else:
		offer.assign(opponent_spirits.filter(func(b: SpiritBinding) -> bool:
			return character.binds(b.source) and not _holds(b.source)))
	return not offer.is_empty()


## Takes offer[index], or releases the offer if index is -1. Returns true if
## both slots are full and choose_slot() must follow.
func choose_offer(index: int) -> bool:
	var chosen: SpiritBinding = offer[index] if index >= 0 else null
	offer.clear()
	if chosen == null:
		return false
	_take(chosen)
	return pending != null


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
			if not pair is Array or pair.size() != 2:
				return null
			var source: FighterDefinition = by_id.get(str(pair[0]))
			if source == null or not StringName(pair[1]) in source.specials:
				return null
			bindings.append(SpiritBinding.new(source, StringName(pair[1])))
		run.set(field, bindings)
	return run


func _take(binding: SpiritBinding) -> void:
	if _holds(binding.source):
		return
	if spirits.size() < SLOTS:
		spirits.append(binding)
	else:
		pending = binding


func _holds(source: FighterDefinition) -> bool:
	return spirits.any(func(b: SpiritBinding) -> bool: return b.source.id == source.id)


func _draw_opponent() -> void:
	var own := tier() == 0
	var pool := roster.filter(func(d: FighterDefinition) -> bool: return (d.kind == character.kind) == own)
	opponent = pool[rng.randi() % pool.size()]
	var candidates: Array[FighterDefinition] = []
	candidates.assign(roster.filter(func(d: FighterDefinition) -> bool: return opponent.binds(d)))
	opponent_spirits.clear()
	for k in mini(CARRIED[place_in_tier()], candidates.size()):
		var pick := candidates[rng.randi() % candidates.size()]
		candidates.erase(pick)
		opponent_spirits.append(SpiritBinding.new(pick, pick.specials[rng.randi() % pick.specials.size()]))


static func _pairs(bindings: Array[SpiritBinding]) -> Array:
	return bindings.map(func(b: SpiritBinding) -> Array: return [String(b.source.id), String(b.move)])
