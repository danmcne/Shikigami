# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a human fighter through a gauntlet of rival warriors, then yokai, then monsters too large to fight on equal terms. Yokai you defeat can be sealed with a finisher and bound as spirits you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository currently contains Prototype 6: three rectangle fighters, each with a signature special, the full combat system, a computer opponent at three difficulties, and a tiered run that saves before every fight. Everything below the "Prototype 6" heading describes that code. Everything above it describes the plan.

## The planned game

### Campaign

A run is a single climb through three tiers. Opponents are shuffled within each tier, and you don't fight every member.

1. **Own-kind tier (short, about 2 fights).** For a human, other humans. Their spirits can't be bound, so this tier is a warm-up and is kept short.
2. **Other-kind tier (about 4 fights).** For a human, yokai and oni at roughly human scale. This is where spirits are bound.
3. **Monster tier (about 2 fights).** Huge bosses under modified rules.

Defining the tiers by kind rather than as "humans, then yokai" means a yokai player gets the same shape of run. About eight fights make a run: long enough to feel like a campaign, short enough that a loss doesn't cost an evening. The run is saved before every fight, including the random generator's state, so it resumes exactly.

Completing the campaign unlocks some of the supernatural fighters as playable characters. Which ones, and on what rule, is still open. The monster-tier bosses remain boss-only.

### Roster (candidates)

- **Human (starting choices):** Miyamoto Musashi, Sasaki Kojirō, Tomoe Gozen, Benkei, Hattori Hanzō, a Buddhist monk, a Shinto exorcist (miko), an onmyōji.
- **Supernatural:** Shuten-dōji (an oni; "oni" is a class of being, not a roster slot), kitsune, tengu, kappa, yuki-onna, jorōgumo, nekomata, tanuki.
- **Monsters:** ushi-oni, nue, gashadokuro.

### Signature specials

Every fighter has one signature special on the special button. It is drawn from their legend, and it recharges after use so it can't be spammed. The same move is what their spirit does when bound and summoned. Fighters may also have a second special; only some have projectiles.

| Fighter | Signature (and as a spirit) | Idea from |
|---|---|---|
| Miyamoto Musashi | Two Heavens: a spinning double cut, in front and behind at once | Niten Ichi-ryū, the two-sword school |
| Sasaki Kojirō | Swallow Reversal: one cut down and back up, striking high and low together, so no single guard height stops it | Tsubame Gaeshi |
| Benkei | Standing Death: a stance that shrugs off hits (super armour) while he advances | his death on the bridge at Koromogawa, standing |
| Hattori Hanzō | Smoke: vanish and reappear elsewhere | the ninja legend |
| Buddhist monk | Meditation: a still, exposed prayer that restores health | after Yoshimitsu's meditation in Tekken |
| Shinto miko | Ofuda: a thrown paper talisman (projectile) | |
| Onmyōji | Paper shikigami: a flight of paper birds (projectile) | |
| Shuten-dōji | Sake: a long, exposed drink that restores health | the "sake-drinking boy" |
| Kitsune | Fox Step: vanish and reappear behind the foe; second special Foxfire (projectile) | kitsune-bi, fox illusions |
| Tengu | Flight: a gliding air dash with a strike | mountain tengu |
| Yuki-onna | Frost Breath: slows whoever it touches | the snow woman |
| Jorōgumo | Web: pulls the opponent in | the spider woman |
| Tanuki | Transformation: takes the shape of the last move used against it | tanuki shapeshifting |

The prototype implements the Musashi, Shuten-dōji and kitsune signatures on its three placeholders.

### Finishers bind spirits

The finisher and the progression mechanic are one feature. Each fighter's finisher is their way of sealing a beaten opponent: Musashi's cut, the monk's sutra, the miko's ofuda, the onmyōji's talisman circle. The loser plays a single shared animation of the spirit being torn loose.

**Humans bind yokai spirits; yokai bind human spirits; neither binds its own kind.** So a finisher is offered only against an opponent of the other kind, after the deciding round, and only if you do not already hold that spirit. The opponent stands dazed for a few seconds, and if the finisher connects, their spirit is bound. Bosses end the run and yield nothing.

### Spirits in combat

- **The spirit's signature.** Summoning makes a translucent copy of the bound fighter, which performs that fighter's signature special and vanishes. The copy has no hurtbox or pushbox, but otherwise behaves exactly as the fighter would. A kitsune spirit steps behind your opponent and strikes, and an oni spirit drinks its sake and heals you. A spirit whose signature is a projectile releases it on your behalf, and one whose signature is a throw grabs. No new animation is needed for any pairing, so art cost grows linearly with the roster rather than as roster × moves.
- **Spirit guard.** Plain guard doesn't stop a spirit's attacks. Spirit guard, which is light+spirit+special held together, stops everything plain guard does and spirits as well.
- **Two slots.** You carry two spirits: spirit summons the first, down+spirit the second. When a new binding finds both slots full, you choose which to give up. If a slot's spirit is cooling down, its input does nothing; it never falls through to the other slot.
- **A cooldown per spirit** rather than a shared meter. Slow, powerful spirits balance themselves through long cooldowns; Shuten-dōji hits hard and rarely.

### Controls

Directions and four buttons: light, heavy, special and spirit. The buttons form the same diamond on keyboard and gamepad. There is no guard button: guard is held light+special.

- **Normals** come from stance plus light or heavy: standing, crouching (lows) or jumping (overheads).
- **Specials** are special alone (the signature), or with a direction: toward for the shared rush, down for the shared anti-air, away for a fighter's second special if it has one. There are no rolling motions.
- **Throws** are light+heavy together.
- **Dashes** are a double tap toward or away.
- **Spirits** are spirit, or down+spirit.
- **Crouching** fighters can crawl.

Rolling motions (down, down-toward, toward + button) were tried and dropped. On a keyboard the button tends to arrive before the roll finishes, where it matches the shorter down+special instead, and nothing can recover it. This follows modern simplified schemes, which use direction+special throughout. Down+special for the anti-air is this game's choice; up+special, the other common convention, would collide with jump.

**Defence.** Guard is held light+special, separate from movement:

- While guard is held you can shuffle slowly in either direction and crouch, but you cannot attack, throw, summon or jump. Release it to act.
- The first of the two presses may start an attack. If the second arrives within your timing window, before that attack is live, the attack is cancelled into guard.
- Guard is not directional: it protects from both sides.
- Standing guard stops mid and overhead attacks; crouching guard stops mid and low.
- Throws beat guard. Light+heavy within 10 frames of being grabbed escapes. Since you can't be pressing anything else while held, a guarding player may simply press heavy while still holding light.
- Spirit guard (light+spirit+special) is needed against spirits.

So every attack has an active answer, and guarding costs you your offence while you hold it.

**Timing.** Two presses count as "together" if they land within a short window. Keyboards, pads and hands differ, so each player calibrates it on the game's real inputs:

- the throw, guard and spirit-guard chords (one hand);
- direction+button across both hands;
- quick deliberate sequences that must stay separate.

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
4. **CPU opponent and run loop.** A CPU at three difficulties, character select, tiered random opponents with random spirits, finishers that bind, slot choice, calibration, practice options, save and resume. *Done.*
5. **Character.** A signature special per fighter, recharge, spirits performing signatures, spirit guard. *Begun in this repository with three signatures.*
6. **Art for three fighters.**
7. **Roster, bosses, presentation.**

### Open questions

- **The own-kind tier.** It is now short. Should it also reward something, since it can't yield spirits?
- **Spirit choice.** With three placeholder fighters, a human player can only ever hold the two yokai spirits. Binding choices only become interesting with a larger roster.
- **Unlocks.** The rule for what completing the campaign unlocks.
- **Spirit attacks.** Should a summoned spirit ever do more than its signature, for example take your next attack inputs for a moment? The signature alone is simpler and is what the prototype does.
- Whether any meter or super exists.
- How the story is presented between fights.

---

## Prototype 6

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| Screen | Keys |
|---|---|
| Menu | 1 new run, 2 continue run, 3 versus, 4 calibrate timing, 5 computer difficulty, 6 game speed, 7 player 1 invincible |
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
| Guard (hold) | J+L | Num 4 + Num 6 | Square + Circle |
| Spirit guard (hold) | J+K+L | Num 4 + Num 2 + Num 6 | Square + Cross + Circle |

Each player's full move list is on screen in that player's keys, and it follows facing. Under each health bar, the first box is your signature's recharge and the others are your spirits.

### The three fighters

Placeholders until real characters exist. They share a base kit, scaled to their proportions: normals, throw, dashes, a toward+special rush, and a down+special anti-air. Each adds its own signature, and two add a second special. Everything is data in `fighters/roster.gd`, and nothing else refers to them by name.

| | Kind | Health | Size, speed, damage | Signature (special) | Second special (away + special) | As a spirit | Finisher (facing right) |
|---|---|---|---|---|---|---|---|
| Balanced | human | 1000 | 1, 1, 1 | Two Heavens: spinning cut, front and back; recharges in 1.5 s | — | spins where you stand | A, D + K |
| Heavy | yokai | 1200 | 1.2×, 0.72×, 1.3× | Sake: two-thirds of a second exposed, then +150 health; 8 s | Oni Grab: a throw with half again the reach | heals you | S, W + K |
| Swift | yokai | 850 | 0.85×, 1.35×, 0.8× | Fox Step: vanish, reappear behind, strike; 2 s | Foxfire: projectile | steps behind your opponent and strikes | D, A + K |

Fox Step leaves about a tenth of a second between reappearing and striking. Guard isn't directional, so that's enough to guard it if you're watching.

### Spirit guard

Spirit attacks pass through plain guard. Hold J+K+L to stop them; spirit guard stops ordinary attacks too.

If you press K first, a summon starts. It is cancelled into guard if J and L follow within your timing window, before the spirit appears. Nothing is spent, because a spirit's recharge starts only when it actually appears. The dummy's full-guard mode uses spirit guard. The computer uses it only sometimes, depending on difficulty.

### Tiers and saving

A run is two own-kind fights, then four other-kind fights; the monster tier will follow when bosses exist. The run saves before every fight. Menu option 2 continues it, restarting the fight you were in, against the same opponent and spirits. The save is cleared when the run ends.

### Calibrating timing

Menu option 4. Press light to say which player you are, then follow the prompts, which name your own keys. There are six steps of five tries:

1. throw (J+I);
2. guard (J+L);
3. spirit guard (J+K+L);
4. toward+special;
5. down+spirit;
6. light then heavy as two separate presses.

Enter saves the result. Calibrations from before this version measured the rolling motion, which inflated the window, so they are ignored. The menu shows each player's window and whether it is still the default.

### Practice options

- **Computer difficulty.** Practice (default), Easy or Normal.
- **Game speed.** 100%, 75% or 50%; everything slows together.
- **Player 1 invincible.** Hits land but take no health.

### Structure

```
project.godot, main.tscn
game/
  main.gd                  screens and flow: menu, select, run, binding choice, versus, calibration
  run.gd                   a run as pure state: tiers, spirits, opponents; save and restore
  calibration.gd           measures a player's chord window on the game's real inputs
  settings.gd              timing, options and the saved run, in user://settings.cfg
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           all key and gamepad bindings
  views/
    bout_view.gd           draws a bout: stage, fighters, spirits, projectiles, HUD, move lists
  combat/
    move_definition.gd     frame data, damage, height, hitboxes, throw, knockdown,
                           invulnerability, motion, spawn, heal, teleport, recharge
    fighter_definition.gd  kind, stats, boxes, moves, commands, signature, summon, finisher
    command.gd             command notation and priority
    input_history.gd       recent presses and holds, the chord window, command matching
    intent.gd              one frame of what a controller wants; guard chords
    fighter.gd             per-fighter state machine; spirits are fighters too
    entity.gd              projectiles
    bout.gd                frame order, hits, guards, throws and escapes, spirits, rounds, finish
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy
    cpu_controller.gd      the computer opponent, three difficulties
  fighters/
    prototype_rect.gd      the shared kit, as data
    roster.gd              Balanced, Heavy, Swift and their signatures
tests/
  selftest.gd              mechanics checks, run only on request
```

### Command notation (for reading the code)

```
7 8 9      6 = toward the opponent, 4 = away, 2 = down, 5 = neutral
4 5 6      A light, B heavy, C special, D spirit
1 2 3      "4C" = away + special
```

The grammar still supports multi-direction motions, with an optional middle diagonal. No fighter uses them.

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 62 checks. This prototype adds checks for:

- Two Heavens striking behind;
- Fox Step crossing over;
- Sake healing once and then recharging;
- an oni spirit healing its summoner, and a fox spirit striking from behind;
- spirits passing plain guard but not spirit guard;
- the oni grab's reach;
- tiers;
- a saved run resuming identically.

The checks confirm the rules behave as written. They cannot tell you whether the game feels good.
