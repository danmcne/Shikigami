# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a human fighter through a gauntlet of rival warriors, then yokai, then monsters too large to fight on equal terms. Yokai you defeat can be sealed with a finisher and bound as spirits you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository currently contains Prototype 4: rectangle fighters with the full combat system, an easy computer opponent, and a simple run against random opponents. Everything below the "Prototype 4" heading describes that code. Everything above it describes the plan.

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

The finisher and the progression mechanic are one feature. Each fighter's finisher is their way of sealing a beaten opponent: Musashi's cut, the monk's sutra, the miko's ofuda, the onmyōji's talisman circle. The loser plays a single shared animation of the spirit being torn loose.

**Humans bind yokai spirits; yokai bind human spirits; neither binds its own kind.** So a finisher is offered only against an opponent of the other kind, after the deciding round. The opponent stands dazed for a few seconds, and if the finisher connects, their spirit is bound. Bosses end the run and yield nothing.

### Spirits in combat

- **One move each.** Every fighter definition names one of its own existing moves as its spirit move. Summoning makes a translucent copy of that fighter, which performs the move and vanishes. The copy has no hurtbox or pushbox, but otherwise behaves exactly as the fighter would. A rushing spirit slides, a spirit whose move fires a projectile releases it on the summoner's behalf, and a spirit whose move is a throw grabs, and can be escaped like any throw. No new animation is needed for any pairing, so art cost grows linearly with the roster rather than as roster × moves.
- **Two slots.** You carry two spirits: spirit summons the first, down+spirit the second. When a new binding finds both slots full, you choose which to give up. If a slot's spirit is cooling down, its input does nothing; it never falls through to the other slot.
- **A cooldown per spirit** rather than a shared meter. Slow, powerful spirits balance themselves through long cooldowns; Shuten-dōji hits hard and rarely.

### Controls

Directions, four attack buttons (light, heavy, special, spirit) and a held guard button. The four attack buttons form the same diamond on keyboard and gamepad, and guard sits under the thumb.

- **Normals** come from stance plus light or heavy: standing, crouching (lows) or jumping (overheads).
- **Specials** are special with a direction (toward, down) or with a rolling motion.
- **Throws** are light+heavy together.
- **Dashes** are a double tap toward or away.
- **Spirits** are spirit, or down+spirit.
- **Crouching** fighters can crawl.

Whether the real roster uses only direction+special or also rolling motions is an open question. The prototype has both so they can be compared by feel.

**Defence.** Guard is its own held button, separate from movement:

- While guard is held you can shuffle slowly in either direction and crouch, but you cannot attack, throw, summon or jump. Release it to act.
- Guard is not directional: it protects from both sides.
- Standing guard stops mid and overhead attacks; crouching guard stops mid and low.
- Throws beat guard. Light+heavy within 10 frames of being grabbed escapes.

So every attack has an active answer, and guarding costs you your offence while you hold it.

**Timing.** Two presses count as "together" (a throw, or a direction with a button) if they land within a short window. Keyboards, pads and hands differ, so each player can calibrate their own window. The calibration measures how far apart their deliberate "together" presses land and how close their quick deliberate sequences come, then places the window between the two.

### Monster-tier bosses

These are not scaled-down fighters. Ushi-oni occupies two or three times a fighter's width. Gashadokuro shows only its upper body, with hands and skull striking from outside the normal play area. Nue flies around the arena. Each boss is bespoke, and that is accepted.

### Modes

- **Campaign**, as above.
- **Versus**: any two playable characters, local only. The finisher is a flourish here; nothing is kept.
- **Training**: any character with any two spirits. This is where absurd combinations get discovered.

### Tone and presentation

- No gore for now.
- Finishers, yes.
- Destructible arenas and usable objects, such as things an oni can pick up and throw, are wanted but secondary. They will arrive as ordinary projectiles.
- Art will be hand-drawn 2D sprites. Each fighter needs one finisher animation, not one per opponent.

### Technical stance

- Godot 4 and GDScript. Tested on 4.4.1; the project targets 4.3 and later.
- Plain code with no ECS or dependency-injection frameworks.
- Fighters are data (`FighterDefinition`, `MoveDefinition`), and the same definition serves every mode. No code refers to a character by name.
- Combat is counted in frames at a fixed 60 Hz.
- Hitboxes, hurtboxes and pushboxes are rectangles, separate from the art.
- Online play is not a goal, so the simulation is not made bit-deterministic.

### Roadmap

The original plan put art second. With no art pipeline in place, art is the costliest and least reversible investment, so it comes after the systems it has to serve are proven on rectangles.

1. **Two rectangles.** *Done.*
2. **Inputs and moves.** *Done.*
3. **Spirits and defence.** *Done.*
4. **CPU opponent and run loop.** An easy CPU, character select, random opponents with random spirits, finishers that bind, slot choice, button-timing calibration. *This repository.* Still to come in this step: tiers, save and resume, and harder CPU settings.
5. **Art for three fighters.**
6. **Roster, bosses, presentation.**

### Open questions

- **The human tier and the kind rule.** A human player binds nothing in the human tier, so a run's progression only starts in the supernatural tier. Should the human tier reward something else, be shorter, or be interleaved with yokai?
- Whether binding a spirit you already hold should be offered at all.
- The unlock rule after completing the campaign.
- Direction+special, rolling motions, or both for the real roster.
- Whether any meter or super exists.
- How the story is presented between fights.

---

## Prototype 4

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| Screen | Keys |
|---|---|
| Menu | 1 run, 2 versus, 3 calibrate button timing |
| Fighter select | 1–3 |
| Run | play; when a beaten opponent stands dazed, perform your finisher (shown on screen) |
| Slots full after a binding | 1 or 2 to replace that slot, 3 to release the new spirit |
| Run over | Enter |
| Versus | F2 player 2: human / dummy / CPU; F3 dummy behaviour; F5 restart; F6 / F7 change fighters |
| Anywhere | Esc to the menu; F1 shows boxes, states and frames |

| | Player 1 | Player 2 | Gamepad |
|---|---|---|---|
| Move / jump / crouch | A D / W / S | ← → / ↑ / ↓ | d-pad or left stick |
| Light | J | Num 4 | X / Square |
| Heavy | I | Num 8 | Y / Triangle |
| Special | L | Num 6 | B / Circle |
| Spirit | K | Num 2 | A / Cross |
| Guard (hold) | Space | Num 0 | right shoulder |

Each player's full move list is on screen in that player's keys, and it follows facing. The first gamepad drives player 1 and the second drives player 2. Keys are bound by physical position, so the shapes hold on non-US layouts.

### Calibrating button timing

From the menu, press 3. Press light and heavy together eight times, the way you would for a throw. Then press them one after the other eight times, as quickly as you can while still meaning two separate presses. The screen shows both measurements and the resulting window. Enter saves it for that player in `user://settings.cfg`; it then applies to throws, throw escapes and direction+button inputs. The default, before calibrating, is presses under 3 frames (50 ms) apart.

Separately from the window, a direction may arrive slightly before or after its button. If special lands a frame before down, you still get the down special.

### Player 1's moves, facing right

| Keys | Move |
|---|---|
| hold Space (with S: low guard) | guard, shuffling slowly with A / D |
| S + A / D | crawl |
| J / I | light / heavy (hold S for lows, jump for overheads) |
| J+I | throw (hold A for a back throw) |
| J+I as you are grabbed | escape the throw |
| D, release, D / A, release, A | dash forward / back |
| L | palm |
| D + L | rush |
| S + L | rising (anti-air, invulnerable at first) |
| S, S+D, D + L | projectile |
| K / S + K | summon first / second spirit |
| finisher input (below) | seal a dazed opponent of the other kind |

### Archetypes

Placeholders until real characters exist. All three share one move set and differ only in data. The names, kinds and inputs live in `fighters/roster.gd`, and nothing else refers to them.

| | Kind | Health | Size | Speed | Damage | Timing | Finisher (facing right) | As a spirit |
|---|---|---|---|---|---|---|---|---|
| Balanced | human | 1000 | 1 | 1 | 1 | — | A, D + K | rushes forward |
| Heavy | yokai | 1200 | 1.2× | 0.72× | 1.3× | +2 frames | S, W + K | a heavy strike |
| Swift | yokai | 850 | 0.85× | 1.35× | 0.8× | −1 frame | D, A + K | throws a projectile |

A human (Balanced) carries yokai spirits and can seal yokai. A yokai carries the human spirit and can seal a human.

### The run

- You pick a fighter and start with no spirits.
- You face six random opponents in a row; mirror matches are possible. Each opponent carries zero, one or two random spirits of the kind it can bind (40% / 40% / 20%).
- Each fight is best of three. Win the deciding round against the other kind and the opponent stands dazed for five seconds; land your finisher to bind their spirit.
- Lose a fight and the run ends.
- Tiers, save and resume come later.

### The CPU

Deliberately easy, and defined by a table of numbers (`CpuController.EASY`):

- It decides every 18 frames.
- It guards about a third of the threats it sees, with a reaction delay, and guards a low at the right height half the time.
- It escapes a fifth of throws.
- It summons ready spirits now and then.

It knows nothing about particular characters. It chooses among the fighter's own normals and commands by whether their hitboxes can reach, and enters them as a player would, frame by frame. Any fighter it is given, it can play.

### Rules added in this prototype

- **Guard button** as described above; holding away from the opponent is now just walking.
- **Crawling** at half speed; shuffling under guard at 0.4× speed. Both are per-fighter data.
- **One "together" window per player**, used for throws, escapes, and late or early directions. A move started from a lesser input can still become a better one until its hitbox appears, within that window.
- **An unavailable input spends itself.** A cooling-down spirit or a projectile already on screen gives nothing, rather than a different move.
- **Kinds and finishers** as described above. Spirits can perform throws.

### Structure

```
project.godot, main.tscn
game/
  main.gd                  screens and flow: menu, select, run, binding choice, versus, calibration
  run.gd                   a run as pure state: fighter, spirits, random opponents
  calibration.gd           measures a player's "together" timing
  settings.gd              per-player settings saved in user://settings.cfg
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           all key and gamepad bindings
  views/
    bout_view.gd           draws a bout: stage, fighters, spirits, projectiles, HUD, move lists
  combat/
    move_definition.gd     frame data, damage, height, hitboxes, throw, knockdown,
                           invulnerability, motion, spawn
    fighter_definition.gd  kind, stats, boxes, moves, commands, summon, spirit move, finisher
    command.gd             command notation and priority
    input_history.gd       recent input, the chord window, and the queries commands need
    intent.gd              one frame of what a controller wants
    fighter.gd             per-fighter state machine; spirits are fighters too
    entity.gd              projectiles
    bout.gd                frame order, hits, throws and escapes, spirits, rounds, finish
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy
    cpu_controller.gd      the easy computer opponent
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
9. Check for KO; a deciding KO against the other kind enters the finish.

### Command notation (for reading the code)

Fighter data writes inputs in fighting-game numpad notation. Players never see it; the screen translates it into keys.

```
7 8 9      6 = toward the opponent, 4 = away, 2 = down, 5 = neutral
4 5 6      A light, B heavy, C special, D spirit
1 2 3      "236C" = down, down-toward, toward, then special
```

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 51 checks. They cover:

- **Earlier rules:** guards, trades, KO, pushboxes, commands, dashes, throws, knockdown, projectiles, invulnerability and spirits.
- **This prototype's additions:**
  - holding away no longer guards;
  - guard shuffling and crawling speeds;
  - no attacking under guard;
  - late directions and per-player windows;
  - no fall-through from a cooling-down spirit;
  - the kind rule;
  - spirit throws landing or escaped;
  - finishers sealing, refused against one's own kind, and timing out;
  - the CPU entering motions and landing hits;
  - run rules;
  - calibration.

The checks confirm the rules behave as written. They cannot tell you whether the game feels good, or whether the CPU is the right difficulty.
