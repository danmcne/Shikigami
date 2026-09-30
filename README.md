# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a human fighter through a gauntlet of rival warriors, then yokai, then monsters too large to fight on equal terms. Each opponent you defeat is bound as a spirit you can summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository currently contains Prototype 1, which consists of two rectangles and the combat core. Everything below the "Prototype 1" heading describes that code. Everything above it describes the plan.

## The planned game

### Campaign

A run is a single climb through three tiers. Opponents are shuffled within each tier, and you don't fight every member.

1. **Human tier (about 4 fights).** You choose a human fighter and face other humans.
2. **Supernatural tier (about 4 fights).** Yokai and oni at roughly human scale.
3. **Monster tier (about 2 fights).** Huge bosses under modified rules.

About ten fights make a run: long enough to feel like a campaign, short enough that a loss doesn't cost an evening. The run is saved after every fight as a small JSON file, including the RNG seed, so it can be resumed.

Completing the campaign unlocks some of the supernatural fighters as playable characters. Which ones, and on what rule, is still open. The monster-tier bosses remain boss-only.

### Roster (candidates)

- **Human (starting choices):** Miyamoto Musashi, Sasaki Kojirō, Tomoe Gozen, Benkei, Hattori Hanzō, a Buddhist monk, a Shinto exorcist (miko), an onmyōji.
- **Supernatural:** Shuten-dōji (an oni; "oni" is a class of being, not a roster slot), kitsune, tengu, kappa, yuki-onna, jorōgumo, nekomata, tanuki.
- **Monsters:** ushi-oni, nue, gashadokuro.

### Finishers bind spirits

The finisher and the progression mechanic are one feature. Each fighter's finisher is their way of sealing a beaten opponent: Musashi's cut, the monk's sutra, the miko's ofuda, the onmyōji's talisman circle. The loser plays a single shared animation of the spirit being torn loose. In the campaign every win ends in a binding. In versus it is simply the finisher.

Every defeated opponent yields a spirit, humans included; a vanquished warrior's ghost bound into service sits comfortably in the lore. The bosses end the run and yield nothing.

### Spirits in combat

- **One move each.** Every fighter definition names one of its own existing attacks as its spirit move. Summoning spawns a translucent copy of that fighter, with no hurtbox, which performs the move and vanishes. No new animation is needed for any pairing, so art cost grows linearly with the roster rather than as roster × techniques.
- **Two slots.** A run yields about eight spirits, but you carry only two, on D and ↓D. Choosing which to keep after each binding is the run's main strategic decision.
- **A cooldown per spirit** rather than a shared meter. Slow, powerful spirits balance themselves through long cooldowns; Shuten-dōji hits hard and rarely.

### Controls (planned)

Directions plus four buttons. A is light, B heavy, C special, and D spirit. Few buttons, with lots of character-specific behaviour. Exact motion inputs, throws and any super are undecided.

### Monster-tier bosses

These are not scaled-down fighters. Ushi-oni occupies two or three times a fighter's width. Gashadokuro shows only its upper body, with hands and skull striking from outside the normal play area. Nue flies around the arena. Each boss is bespoke, and that is accepted.

### Modes

- **Campaign**, as above.
- **Versus**: any two playable characters, local only.
- **Training**: any character with any two spirits. This is where absurd combinations get discovered.

### Tone and presentation

- No gore for now.
- Finishers, yes.
- Destructible arenas and usable objects, such as things an oni can pick up and throw, are wanted but secondary. They will arrive as ordinary projectiles.
- Art will be hand-drawn 2D sprites. Each fighter needs one finisher animation, not one per opponent.

### Technical stance

- Godot 4 and GDScript. Tested on 4.4.1; the project targets 4.3 and later.
- Plain code with no ECS or dependency-injection frameworks.
- Fighters are data (`FighterDefinition`, `AttackDefinition`), and the same definition serves every mode.
- Combat is counted in frames at a fixed 60 Hz: startup, active and recovery; hitstun and blockstun; hitstop.
- Hitboxes, hurtboxes and pushboxes are rectangles, separate from the art.
- Online play is not a goal, so the simulation is not made bit-deterministic.

### Roadmap

1. **Two rectangles.** Movement, jump, crouch, guard, light and heavy attacks, hit detection, health, rounds. *(This repository.)* If this doesn't feel good, nothing later matters.
2. **Three real fighters:** Musashi (weapon fighter), Benkei (heavyweight), kitsune (trickster). Sprites, specials, throws.
3. **The campaign loop:** a CPU opponent good enough to be worth fighting, finisher/binding, spirit slots and cooldowns, tiered shuffled encounters, save/resume.
4. **The roster:** six to eight more fighters.
5. **Bosses:** the per-boss rule changes.
6. **Presentation:** art, sound, menus, story framing.

### Open questions

- The unlock rule after completing the campaign.
- Whether binding is ever optional, and how slot replacement is presented.
- CPU opponent design. It is the largest unplanned cost before the campaign is playable.
- Throws, specials, and whether any meter or super exists.
- How the story is presented between fights.

---

## Prototype 1

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| | Player 1 | Player 2 |
|---|---|---|
| Move / jump / crouch | A D / W / S | ← → / ↑ / ↓ |
| Light | F | Numpad 1 or `,` |
| Heavy | G | Numpad 2 or `.` |
| Gamepad | first pad | second pad |

On a gamepad, light is X (Square) and heavy is Y (Triangle); the d-pad and left stick both move. Function keys:

- **F1** shows hurtboxes (cyan), pushboxes (yellow), live hitboxes (red), and each fighter's state and frame.
- **F2** cycles player 2 between human control and a training dummy (idle, crouch, guard, crouch guard).
- **F5** restarts the bout.

The attacking limb is drawn as an outline during startup, solid while active, and faint during recovery.

### Rules implemented

- **Guard by holding away from the opponent.** Standing guard stops mid and high attacks; crouching guard stops mid and low. Holding back while the opponent is attacking guards in place instead of walking away.
- **Attack heights.** Standing normals are mid, crouching normals are low, and jumping normals are high (overheads).
- **Geometry, not rules, decides whiffs.** Standing light sits at chest height and passes over a crouch, while standing heavy reaches low enough to hit one.
- **Simultaneous hits trade.** Both land, neither cancels the other.
- **Hitstop** freezes both fighters for a few frames on contact.
- **Input buffer.** A press made up to 5 frames before the fighter can act still comes out.
- **Corner recoil.** A cornered defender can't slide back, so the attacker recoils instead.
- **Rounds.** Best of three, with double KO counting for no one.

All numbers live in `game/fighters/prototype_rect.gd`. They are starting points for tuning feel, not balanced values.

### Structure

```
project.godot, main.tscn
game/
  main.gd                  view: reads input, steps the bout at 60 Hz, draws rectangles
  input_setup.gd           all key and gamepad bindings, registered in code
  combat/
    attack_definition.gd   frame data, damage, height, local hitboxes
    fighter_definition.gd  stats, hurtboxes, pushbox, attack table
    intent.gd              one frame of what a controller wants
    fighter.gd             per-fighter state machine (pure logic)
    bout.gd                frame order, hits, pushboxes, stage, rounds
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy; the seed of CPU opponents
  fighters/
    prototype_rect.gd      the one prototype fighter, as data
tests/
  selftest.gd              mechanics checks, run only on request
```

The simulation (`combat/`) has no nodes, drawing or input, and the view only reads it. That separation is what will let sprites replace rectangles, and a CPU replace a player, without touching the rules.

Each frame runs in a fixed order: face the opponent, step both fighters, push apart and clamp to the stage, resolve hits, check for KO.

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

This checks that the rules behave as written: guards against each height, the whiff over a crouch, trades, KO and round reset, and pushboxes never overlapping. It cannot tell you whether the game feels good; only playing it can.
