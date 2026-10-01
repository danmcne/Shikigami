# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a human fighter through a gauntlet of rival warriors, then yokai, then monsters too large to fight on equal terms. Each opponent you defeat is bound as a spirit you can summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository currently contains Prototype 3: rectangle fighters with the combat core, the move system, spirits and throw escapes. Everything below the "Prototype 3" heading describes that code. Everything above it describes the plan.

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

- **One move each.** Every fighter definition names one of its own existing moves as its spirit move. Summoning makes a translucent copy of that fighter, with no hurtbox or pushbox, which performs the move and vanishes. It moves exactly as the fighter would: a rushing spirit slides, and a spirit whose move throws a projectile releases one on the summoner's behalf. No new animation is needed for any pairing, so art cost grows linearly with the roster rather than as roster × moves. Spirit moves must be strikes or projectiles; throws are excluded, since a body-less copy has nothing to grab with.
- **Two slots.** A run yields about eight spirits, but you carry only two: D summons the first, down+D the second. Choosing which to keep after each binding is the run's main strategic decision.
- **A cooldown per spirit** rather than a shared meter. Slow, powerful spirits balance themselves through long cooldowns; Shuten-dōji hits hard and rarely.

### Controls

Directions plus four buttons: A light, B heavy, C special, D spirit. The buttons form the same diamond on keyboard and gamepad (see below), so what you learn on one transfers to the other.

- **Normals** come from stance plus light or heavy: standing, crouching (lows) or jumping (overheads).
- **Specials** are special with a direction (toward, down) or with a rolling motion.
- **Throws** are light+heavy together.
- **Dashes** are a double tap toward or away.
- **Spirits** are spirit, or down+spirit.

Whether the real roster uses only direction+special or also rolling motions is an open question. The prototype has both so they can be compared by feel.

**Defence.** Every attack has an active answer.

| Attack | Answer |
|---|---|
| Mid strike | Hold away from the opponent, standing or crouching |
| Low strike (crouching attacks) | Hold down+away |
| Overhead (jumping attacks) | Hold away while standing |
| Throw | Press light+heavy within 10 frames of being grabbed |

Guarding means holding a direction, so you can't attack while you guard. You also have to choose a height, which is what lets lows and overheads through a careless guard. Throws beat any guard but can be escaped, so a defender who is paying attention can stop everything. That cost is deliberate.

### Monster-tier bosses

These are not scaled-down fighters. Ushi-oni occupies two or three times a fighter's width. Gashadokuro shows only its upper body, with hands and skull striking from outside the normal play area. Nue flies around the arena. Each boss is bespoke, and that is accepted.

### Modes

- **Campaign**, as above.
- **Versus**: any two playable characters, local only.
- **Training**: any character with any two spirits. This is where absurd combinations get discovered.

In versus and training the finisher is a flourish with no consequence; binding only matters in the campaign. That is why finishers are built with the campaign loop, not before it.

### Tone and presentation

- No gore for now.
- Finishers, yes.
- Destructible arenas and usable objects, such as things an oni can pick up and throw, are wanted but secondary. They will arrive as ordinary projectiles.
- Art will be hand-drawn 2D sprites. Each fighter needs one finisher animation, not one per opponent.

### Technical stance

- Godot 4 and GDScript. Tested on 4.4.1; the project targets 4.3 and later.
- Plain code with no ECS or dependency-injection frameworks.
- Fighters are data (`FighterDefinition`, `MoveDefinition`), and the same definition serves every mode.
- Combat is counted in frames at a fixed 60 Hz: startup, active and recovery; hitstun and blockstun; hitstop.
- Hitboxes, hurtboxes and pushboxes are rectangles, separate from the art.
- Online play is not a goal, so the simulation is not made bit-deterministic.

### Roadmap

The original plan put art second. With no art pipeline in place, art is the costliest and least reversible investment, so it now comes after the systems it has to serve are proven on rectangles.

1. **Two rectangles.** Movement, jump, crouch, guard, light and heavy attacks, hit detection, health, rounds. *Done.*
2. **Inputs and moves on rectangles.** Four-button layout, command notation, dashes, specials, projectiles, throws, knockdown, invulnerability. *Done.*
3. **Spirits and defence on rectangles.** Spirit summoning with two slots and per-spirit cooldowns, throw escape, three rectangle archetypes that differ only in data. *This repository.*
4. **CPU opponent and campaign loop.** An opponent worth fighting, tiered shuffled encounters, finishers that bind spirits, slot replacement, save and resume.
5. **Art for three fighters:** Musashi, Benkei, kitsune.
6. **Roster, bosses, presentation.**

### Open questions

- The unlock rule after completing the campaign.
- Whether binding is ever optional, and how slot replacement is presented.
- CPU opponent design. It is the largest unplanned cost before the campaign is playable.
- The finisher's input, and whether a missed finisher still binds the spirit.
- Direction+C, motion+C, or both for the real roster.
- Whether any meter or super exists.
- How the story is presented between fights.

---

## Prototype 3

Three rectangle archetypes with the full move system, spirits and throw escapes. All earlier rules still hold.

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| | Player 1 | Player 2 | Gamepad |
|---|---|---|---|
| Move / jump / crouch | A D / W / S | ← → / ↑ / ↓ | d-pad or left stick |
| Light | J | Num 4 | X / Square |
| Heavy | I | Num 8 | Y / Triangle |
| Special | L | Num 6 | B / Circle |
| Spirit | K | Num 2 | A / Cross |

The first gamepad drives player 1 and the second drives player 2. Keys are bound by physical position, so the shapes hold on non-US layouts. Player 2's keyboard binding needs a numpad; without one, use a gamepad.

**Each player's full move list is on screen, written in that player's keys and the current facing.** When you switch sides, "toward" changes from D to A and the list changes with it.

| Key | Effect |
|---|---|
| F1 | Show hurtboxes (cyan), pushboxes (yellow), live hitboxes (red), and each fighter's state, move and frame |
| F2 | Switch player 2 between human and training dummy |
| F3 | Change the dummy's behaviour: idle, crouch, stand guard, crouch guard, full guard |
| F5 | Restart the bout |
| F6 / F7 | Change player 1's / player 2's fighter |

The one-height guards let lows or overheads through. Full guard reads each incoming attack and guards at the right height. Every guarding mode escapes every throw.

On screen:

- A translucent fighter is invulnerable.
- A fighter lying flat is knocked down.
- A yellow-tinted fighter is held by a throw and can still escape.
- Summoned spirits are pale, translucent copies.

### Player 1's moves, facing right

| Keys | Move |
|---|---|
| hold A / hold S+A | guard / low guard |
| J / I | light / heavy (hold S for lows, jump for overheads) |
| J+I | throw (hold A for a back throw) |
| J+I as you are grabbed | escape the throw |
| D, release, D | dash forward |
| A, release, A | dash back |
| L | palm: mid-range strike, heavy knockback |
| D + L | rush: slides forward, knocks down, punishable if guarded |
| S + L | rising: anti-air, invulnerable at first, knocks down, long landing recovery |
| S, S+D, D + L | projectile: crosses the stage, one at a time |
| K / S + K | summon first / second spirit |

The rising move also reaches a standing opponent up close. With 3 frames of startup and invulnerability, it beats almost anything at that range. Treat it as a tuning target.

### Archetypes

All three share one move set and differ only in numbers. This tests whether data alone can make fighters feel different.

| | Health | Size | Speed | Damage | Timing | As a spirit |
|---|---|---|---|---|---|---|
| Balanced | 1000 | 1 | 1 | 1 | — | rushes forward |
| Heavy | 1200 | 1.2× | 0.72× | 1.3× | +2 frames startup and recovery | a heavy strike in front |
| Swift | 850 | 0.85× | 1.35× | 0.8× | −1 frame | throws a projectile from behind you |

Each fighter carries the other two as spirits. Cooldowns are 6 s (Balanced), 5 s (Heavy) and 4 s (Swift); the bar under each slot refills as it recovers. Size changes geometry, so matchups shift. For example, a crouch normally ducks a standing light, but Heavy's crouch is tall enough that Balanced's and Swift's standing lights still hit it, and Swift's also hits a crouching Balanced.

### Command notation (for reading the code)

Fighter data writes inputs in fighting-game numpad notation. Players never see it; the on-screen lists translate it into keys. A pattern is directions relative to facing, then buttons:

```
7 8 9      6 = toward the opponent, 4 = away, 2 = down, 5 = neutral
4 5 6      A light, B heavy, C special, D spirit
1 2 3      "236C" = down, down-toward, toward, then special
```

### Rules added in this prototype

- **Throw escape.** A throw that connects holds its victim for 10 frames, with the fight frozen. Light+heavy in that window, or up to 3 frames before it, breaks the throw, and both fighters are pushed apart.
- **Spirits.** Summoning is a short gesture. The spirit appears on its first active frame, as a copy of its source fighter performing that fighter's spirit move. A spirit strikes but can't be hit, pushed or thrown. Its projectiles belong to the summoner. Cooldown starts only when the spirit actually appears, so being hit during the gesture costs nothing but the time.
- **One live projectile per move.** A move can't be repeated while its projectile is alive. This replaces Prototype 2's "one projectile per fighter".

### Structure

```
project.godot, main.tscn
game/
  main.gd                  view: input, stepping at 60 Hz, rectangles, HUD, move lists
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           all key and gamepad bindings, registered in code
  combat/
    move_definition.gd     frame data, damage, height, hitboxes, throw, knockdown,
                           invulnerability, motion, spawn
    fighter_definition.gd  stats, boxes, moves, commands, summon gesture, spirit move
    command.gd             command notation and priority
    input_history.gd       recent input and the queries commands need
    intent.gd              one frame of what a controller wants
    fighter.gd             per-fighter state machine; spirits are fighters too
    entity.gd              projectiles
    bout.gd                frame order, hits, throws and escapes, spirits, stage, rounds
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy; the seed of CPU opponents
  fighters/
    prototype_rect.gd      the base fighter, as data
    roster.gd              Balanced, Heavy, Swift
tests/
  selftest.gd              mechanics checks, run only on request
```

The simulation (`combat/`) has no nodes, drawing or input devices. The view only reads it. Each frame runs in a fixed order:

1. Record input.
2. If a throw is holding its victim, check for an escape and stop here.
3. If in hitstop, stop here.
4. Face the opponent and flag threats.
5. Step fighters, spirits and projectiles.
6. Release spawns and summons.
7. Push the fighters apart and clamp them to the stage.
8. Resolve hits: strikes, then throws.
9. Check for KO.

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

The self-test checks that the rules behave as written: guards against each height, trades, KO and round reset, pushboxes, command recognition and facing, special priority, dashes, chord leniency, throws, back throws, throw against throw and strike, knockdown and rising invulnerability, projectiles, throw escape inside and after the window, full guard against every attack type, spirit strikes, cooldowns, moving spirits, spirit projectiles, and key rendering. It cannot tell you whether any of this feels good.
