# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a human fighter through a gauntlet of rival warriors, then yokai, then monsters too large to fight on equal terms. Each opponent you defeat is bound as a spirit you can summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository currently contains Prototype 2: two rectangles with the combat core and the move system. Everything below the "Prototype 2" heading describes that code. Everything above it describes the plan.

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

### Controls

Directions plus four buttons: A light, B heavy, C special, D spirit. The buttons form the same diamond on keyboard and gamepad (see Prototype 2 below), so what you learn on one transfers to the other.

Normals come from stance plus A or B. Specials are C with a direction or a motion, throws are A+B, and dashes are a double tap. All of these are written in one command notation (numpad directions relative to facing, then buttons) and matched by one mechanism. Whether the real roster uses simple direction+C, classic motions like 236C, or both is an open question; the prototype has both so they can be compared by feel.

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

The original plan put art second. With no art pipeline in place, art is the costliest and least reversible investment, so it now comes after the systems it has to serve are proven on rectangles.

1. **Two rectangles.** Movement, jump, crouch, guard, light and heavy attacks, hit detection, health, rounds. *Done.*
2. **Inputs and moves on rectangles.** Four-button layout, command notation, dashes, specials, projectiles, throws, knockdown, invulnerability. *This repository.*
3. **Spirits on rectangles.** Finisher and binding, two slots, per-spirit cooldowns, and several rectangle archetypes (heavy, long-reach, fast) that differ only in data.
4. **CPU opponent and campaign loop.** An opponent worth fighting, tiered shuffled encounters, save and resume.
5. **Art for three fighters:** Musashi, Benkei, kitsune.
6. **Roster, bosses, presentation.**

### Open questions

- The unlock rule after completing the campaign.
- Whether binding is ever optional, and how slot replacement is presented.
- CPU opponent design. It is the largest unplanned cost before the campaign is playable.
- Direction+C, motion+C, or both for the real roster.
- Whether any meter or super exists.
- How the story is presented between fights.

---

## Prototype 2

Two rectangles with the full move system. Prototype 1's rules all still hold.

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| | Player 1 | Player 2 | Gamepad |
|---|---|---|---|
| Move / jump / crouch | A D / W / S | ← → / ↑ / ↓ | d-pad or left stick |
| A: light | J | Num 4 | X / Square |
| B: heavy | I | Num 8 | Y / Triangle |
| C: special | L | Num 6 | B / Circle |
| D: spirit (not yet used) | K | Num 2 | A / Cross |

The first gamepad drives player 1 and the second drives player 2. Keys are bound by physical position, so the shapes hold on non-US layouts. Player 2's keyboard binding needs a numpad; without one, use a gamepad.

- **F1** shows hurtboxes (cyan), pushboxes (yellow), live hitboxes (red), and each fighter's state, move and frame.
- **F2** cycles player 2 between human control and a training dummy (idle, crouch, guard, crouch guard).
- **F5** restarts the bout.

A fighter drawn translucent is invulnerable. A knocked-down fighter lies flat.

### The prototype fighter's moves

Directions are numpad notation relative to facing: 6 is toward the opponent, 4 away, 2 down.

| Input | Move | What it is for |
|---|---|---|
| C | palm | Mid-range strike with heavy knockback. |
| 6C | rush | Slides forward; knocks down on hit, punishable on guard. |
| 2C | rising | Anti-air. Invulnerable for its first 8 frames, then launches upward; knocks down; long landing recovery. |
| 236C | projectile | Crosses the stage. Only one at a time; opposing projectiles cancel. |
| A+B | throw | Beats guard. Loses to any strike landing on the same frame; two throws cancel. Hold 4 to throw backward. |
| 66 / 44 | dash forward / back | A short burst of ground movement. |

The specials deliberately mix direction+C and motion+C, so both styles can be judged by feel before the real roster commits to one.

The rising move's hitbox also reaches a standing opponent at close range. With 3 frames of startup and invulnerability, it beats almost anything up close and is punishable only when it whiffs or is guarded. That is a known shape of problem in fighting games, and a tuning target, not a bug.

### Rules added in this prototype

- **Commands.** Each fighter lists command patterns such as `"236C"`, `"6C"`, `"AB"` or `"656"`, mapped to moves. The pattern's directions must occur in order within a short window, and the last must be held at the button press. When several patterns match, one with buttons beats one without, then more directions beat fewer. This is why 236C is a projectile even though it ends in 6C.
- **Input leniency.** For 2 frames after a normal starts, a throw or special that now matches replaces it. A then B one frame later is still a throw.
- **Input during hitstop** is recorded, so it isn't lost.
- **Knockdown.** Some moves knock down instead of causing hitstun. A knocked-down fighter is invulnerable until they stand.
- **Launched moves.** A move with upward motion keeps running after landing, so its recovery happens on the ground.
- **Entities.** A move can release a body-less performer of another move. Today that is a projectile. The spirit summon in Prototype 3 will be the same mechanism with a different move.

### Structure

```
project.godot, main.tscn
game/
  main.gd                  view: reads input, steps the bout at 60 Hz, draws rectangles
  input_setup.gd           all key and gamepad bindings, registered in code
  combat/
    move_definition.gd     frame data, damage, height, hitboxes, throw, knockdown,
                           invulnerability, motion, spawn
    fighter_definition.gd  stats, hurtboxes, pushbox, moves, commands
    command.gd             command notation and priority
    input_history.gd       recent input and the queries commands need
    intent.gd              one frame of what a controller wants
    fighter.gd             per-fighter state machine (pure logic)
    entity.gd              projectiles now, spirits later
    bout.gd                frame order, hits, throws, clashes, pushboxes, stage, rounds
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy; the seed of CPU opponents
  fighters/
    prototype_rect.gd      the prototype fighter, as data
tests/
  selftest.gd              mechanics checks, run only on request
```

The simulation (`combat/`) has no nodes, drawing or input devices. The view only reads it. Each frame runs in a fixed order:

1. Record input.
2. If in hitstop, stop here.
3. Face the opponent and flag threats.
4. Step the fighters.
5. Step and spawn entities.
6. Push the fighters apart and clamp them to the stage.
7. Resolve hits: strikes, then throws.
8. Check for KO.

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

The self-test checks that the rules behave as written: guards against each height, trades, KO and round reset, pushboxes, command recognition and facing, special selection and priority, dashes, chord leniency, throws against guard, back throws, throw against throw, strike against throw, knockdown invulnerability, projectiles, and the rising move's invulnerable start. It cannot tell you whether any of this feels good; only playing it can.
