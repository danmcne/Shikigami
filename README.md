# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a fighter through a gauntlet of rivals of your own kind, then of the other kind, then of monsters too large to fight on equal terms. Opponents of the other kind can be sealed with a finisher and bound as spirits, which you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository contains Prototype 7: all sixteen planned humans and yokai, still drawn as rectangles, each with two specials from its legend. Everything below the "Prototype 7" heading describes that code. Everything above it describes the design.

## The design

### Kinds and binding

Every fighter is a **human** or a **yokai**. Humans bind yokai spirits; yokai bind human spirits; neither binds its own kind.

After winning the deciding round against the other kind, the beaten opponent stands dazed for five seconds. If your finisher connects, their spirit is sealed. The finisher input is the same for everyone (away, toward + spirit); each fighter has its own way of performing it. A spirit you already hold can't be sealed again.

Sealing then asks two questions:

1. **Which of the fighter's two specials will the spirit perform?**
2. **If both of your slots are full, which spirit do you give up?** Or you can release the new one.

### The roster

Eight humans and eight yokai. Each has two specials: one on special, one on away + special. Each special recharges after use. The specials are drawn from legend.

| | Kind | Special | Away + special |
|---|---|---|---|
| Miyamoto Musashi | human | Two Heavens: one sword high, one low, at once; no single guard height stops it | Void Stance: a counter; struck during it, he cuts back |
| Sasaki Kojirō | human | Swallow Cut: Tsubame Gaeshi, an arc covering above and ahead; also in the air | Drying Pole: a thrust of exceptional reach with his overlong nodachi |
| Tomoe Gozen | human | Naginata Wheel: a full circle, front and back; also in the air | Naginata Sweep: a long low sweep that knocks down |
| Benkei | human | Standing Death: advances with armour, after his death standing on the bridge | Seven Weapons: a long-reach grapple |
| Hattori Hanzō | human | Kawarimi: a counter; struck, he vanishes and strikes from behind | Shuriken: a fast, light projectile; also in the air |
| Buddhist monk | human | Meditation: long, exposed, then restores health | Sutra Palm: a strike that drives the opponent far back |
| Shinto miko | human | Ofuda: a thrown paper talisman | Warding Seal: a talisman laid on the ground ahead, a low trap |
| Onmyōji | human | Paper Birds: shikigami that climb as they fly, an anti-air projectile | Five-Element Seal: a barrier that stops projectiles and repels whoever walks in |
| Shuten-dōji | yokai | Sake: drinks, armoured and unbothered, then heals and keeps the armour a few seconds | Kanabō: the iron club, a slow armoured overhead |
| Kitsune | yokai | Fox Step: vanishes and reappears behind to strike | Foxfire: kitsune-bi, a projectile |
| Tengu | yokai | Gale Fan: a gust that hurls more than it hurts | Flight: a gliding overhead strike; also in the air |
| Kappa | yokai | Sumo Grab: kappa challenge travellers to sumo | Water Jet: from the dish on its head, a low projectile |
| Yuki-onna | yokai | Frost Breath: short range; slows whoever it touches | Icicle: falls from above some way ahead, an overhead |
| Jorōgumo | yokai | Web: a strand that reels the victim in | Ceiling Drop: up out of reach and down on top of you |
| Nekomata | yokai | Pounce: a leaping overhead | Twin Tails: two tails, low and mid at once |
| Tanuki | yokai | Belly Drum: hara-tsuzumi, a low shockwave to both sides | Leaf Disguise: a counter; a leaf on the head and it is a statue that strikes back |

Every fighter also shares a kit: six normals, a throw, two dashes, a rush (toward + special), a rising anti-air (down + special), the summon gesture, and the finisher. Their proportions (size, speed, health, power, tempo) differ.

### Spirits in combat

- **The spirit's chosen special.** Summoning makes a translucent copy of the bound fighter, which performs the special you chose when you bound it, then vanishes. The copy has no hurtbox or pushbox, but otherwise behaves as the fighter would: a fox steps behind your opponent; a Jorōgumo's web reels them in. Effects a fighter gives itself (healing, armour) go to you, the summoner. No new animation is needed for any pairing, so art cost grows linearly with the roster.
- **Two slots.** Spirit summons the first, down + spirit the second. Each has its own recharge; a slot that is recharging does nothing, and never falls through to the other.
- **Counters are a poor choice of spirit.** A spirit can't be struck, so its counter never triggers. The binding screen makes that choice the player's.

### Controls

Directions and four buttons: light, heavy, special and spirit. The buttons form the same diamond on keyboard and gamepad.

- **Normals:** stance plus light or heavy. Crouching normals are lows; jumping normals are overheads.
- **Specials:** special, away + special, or the shared toward + special and down + special. Specials marked "also in the air" can be used mid-jump; the rest can't.
- **Throws:** light+heavy.
- **Dashes:** double tap toward or away.
- **Spirits:** spirit, or down + spirit.
- **Crouching:** crouching fighters crawl.
- **No rolling motions.** They were tried and dropped, because on a keyboard the button tends to arrive before the roll is finished.

### Defence

Two guards, each held, each stopping a different threat:

| Guard | Hold | Stops | Doesn't stop |
|---|---|---|---|
| Guard | light+special | the opponent's own strikes and projectiles | spirits |
| Spirit guard | light+spirit+special | spirits' strikes and projectiles | the opponent's own attacks |

Holding spirit guard all the time would leave you open to everything else, so you choose which threat to guard against.

- **Heights.** Either guard stands or crouches: standing stops mid and overhead, crouching stops mid and low. Attacks that strike high and low at once (Two Heavens) pass both.
- **Throws** beat guard. Light+heavy within 10 frames of being grabbed escapes. Since nothing else can happen while you're held, a guarding player may simply press heavy while still holding light.
- **Guarding costs offence.** While guarding you can shuffle and crouch, but not attack, throw, summon or jump.
- **Armour** (Benkei's stance, the oni's sake and club) takes damage without being interrupted. Throws ignore armour.
- **Counters** (Musashi, Hanzō, Tanuki) are beaten by throws and by waiting them out.

### Timing

Two presses count as "together" if they land within a short window. Keyboards, pads and hands differ, so each player calibrates the window on the game's real chords:

- throw, guard and spirit guard on one hand;
- direction + button across both hands;
- quick deliberate sequences that must stay separate.

### Campaign

A run is a single climb through three tiers. Opponents are shuffled within each tier, and you don't fight every member.

1. **Own-kind tier, short (about 2 fights).** Their spirits can't be bound.
2. **Other-kind tier (about 4 fights).** Binding happens here.
3. **Monster tier (1–2 fights).** Huge bosses under modified rules (below).

The run is saved before every fight, including the random generator's state, so it resumes exactly. Completing the campaign will unlock things; what, and on what rule, is open.

### Monsters: planning

Bosses are not scaled-up fighters. Each is a bespoke encounter on a wider stage, built from the same frame-based combat but with several new capabilities. Shared rules:

- **One long round with phases**, not best of three. Damage to the boss is tracked against parts and a core.
- **Parts.** A boss is several hurtboxes with their own health (legs, hands, heads). Breaking a part changes what the boss can do; the core ends the fight.
- **Telegraphs.** Big attacks show where they will land before they land. The engine already has the mechanism: an entity whose start-up is long and whose hitbox appears later.
- **Attacks from outside the fighting space.** Hands, tails and lightning arrive from beyond the stage edges or from above.
- **No throws against a boss,** and a boss can't be bound. Spirits work normally against it. Boss strikes are guarded with plain guard, at the usual heights.

| Monster | Legend | Encounter |
|---|---|---|
| Ushi-oni | ox-headed, spider-bodied shore demon | Fills a third of the stage. Leg stabs reach both sides at once; a charge crosses the whole stage and must be jumped; poison breath slows. Each leg is a part, and losing legs slows it. Its head is reachable only after a charge, when it lowers. |
| Gashadokuro | giant skeleton of the unburied dead | Only its upper body is visible, rising behind the stage. Hands slam in from the stage edges and sweep across; the skull bites from above. The hands are parts. The skull is reachable only after a hand is broken, by jumping to its jaw. Breaking bones throws debris as projectiles. |
| Nue | chimera (monkey face, tanuki body, tiger limbs, snake tail) in a thundercloud; shot down by Minamoto no Yorimasa | Flies around the arena out of normal reach. Lightning strikes marked spots on the floor, the snake tail strikes from behind, and dives are overheads. It is vulnerable when it dives, and to anti-air projectiles. Bringing it down grounds it for a final phase. |
| Ōmukade (candidate) | the giant centipede shot by Tawara Tōda | A segmented body that crosses the stage in waves; segments are parts. |
| Yamata no Orochi (candidate) | eight-headed serpent | Several heads as parts, each with its own attack. |

Build order for bosses: Ushi-oni first (closest to a fighter: a large body on the ground), then Gashadokuro (attacks from off-stage), then Nue (flight). Engine work this needs, in order:

1. Bodies made of parts with their own health.
2. A wider stage and a camera.
3. Boss behaviour as phase tables of attack patterns (separate from the CPU opponent).
4. Spawn positions relative to the stage, not only to the performer.
5. Floor markers for telegraphs.

### Modes

- **Campaign**, as above.
- **Versus:** any two fighters, local only.
- **Training:** any fighter with any two spirits.

### Tone, art and technology

- No gore for now; finishers yes. Destructible arenas and usable objects are wanted but secondary.
- Art will be hand-drawn 2D sprites. Each fighter needs one finisher animation, not one per opponent.
- Godot 4 and GDScript, tested on 4.4.1, targeting 4.3 and later. Plain code; fighters are data, and no code refers to a character by name.
- Combat is counted in frames at a fixed 60 Hz. Boxes are rectangles, separate from the art.
- Online play is not a goal, so the simulation is not made bit-deterministic.

### Roadmap

Art comes after the systems it has to serve are proven on rectangles.

1. **Two rectangles.** *Done.*
2. **Inputs and moves.** *Done.*
3. **Spirits and defence.** *Done.*
4. **CPU and run loop.** *Done.*
5. **Character.** Sixteen named fighters, two specials each, spirits performing a chosen special, exclusive guards. *Done in this repository.*
6. **Monsters.** The engine work above, then Ushi-oni.
7. **Art** for a first handful of fighters.
8. **Presentation.** Menus, sound, story between fights.

### Open questions

- **The own-kind tier.** It's short; should it also reward something, since it can't yield spirits?
- **Unlocks.** What completing the campaign unlocks.
- **Spirit inputs.** Should a summoned spirit ever take your attack inputs for a moment, instead of performing one chosen special?
- **Balance.** The specials' numbers are first guesses. Several (Two Heavens, the counters, the traps) need play to tune.

---

## Prototype 7

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| Screen | Keys |
|---|---|
| Menu | 1 new run, 2 continue run, 3 versus, 4 calibrate timing, 5 computer difficulty, 6 game speed, 7 player 1 invincible |
| Fighter select | A / D or arrows to move, Enter or J to begin; the selected fighter's specials are described below the list |
| Run | play; when a beaten opponent stands dazed, perform the finisher shown on screen |
| After sealing | 1 or 2 to choose the spirit's special; then, if slots are full, 1 or 2 to replace, 3 to release |
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
| Finisher | A, D + K (away, toward + spirit) | ←, → + Num 2 | |

On screen:

- Each fighter's name is shown above it.
- Effects are announced over the fighter: "+100", "ARMOUR", "COUNTER", "SLOWED".
- Armour shows as a gold outline, and slow as a blue tint.
- Under each health bar are four recharge boxes: your two specials, then your two spirits.
- Each player's full move list is on screen in that player's keys, and it follows facing.

### What changed

- **Sixteen named fighters** replace the three placeholders, each with two specials (table above). Proportions differ; specials are authored per fighter.
- **New effects** in `MoveDefinition`: armour, counters, slow, high-and-low strikes, and specials usable in the air. Pulls are negative knockback; traps and barriers are stationary projectiles.
- **Exclusive guards.** Spirit guard stops spirits only, plain guard everything else.
- **Binding chooses a special.** Spirits store which special they perform.
- **One finisher input** for every fighter.
- **Sake is visible.** It used to only heal, which did nothing at full health. It now also grants about three and a half seconds of armour, and both effects are announced. As a spirit it heals and armours you.
- **Saves.** Saved runs from earlier versions are ignored, since the fighters they name no longer exist.

### Structure

```
project.godot, main.tscn
game/
  main.gd                  screens and flow: menu, select, run, binding choices, versus, calibration
  run.gd                   a run as pure state: tiers, bindings, opponents; save and restore
  calibration.gd           measures a player's chord window on the game's real inputs
  settings.gd              timing, options and the saved run, in user://settings.cfg
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           all key and gamepad bindings
  views/
    bout_view.gd           draws a bout: stage, fighters, spirits, projectiles, HUD, notices, move lists
  combat/
    move_definition.gd     frame data, damage, height, hitboxes and every move effect
    fighter_definition.gd  kind, stats, boxes, moves, commands, two specials, summon, finisher
    spirit_binding.gd      a bound spirit: source fighter and chosen special
    command.gd             command notation and priority
    input_history.gd       recent presses and holds, the chord window, command matching
    intent.gd              one frame of what a controller wants; the guard chords
    fighter.gd             per-fighter state machine; spirits are fighters too
    entity.gd              projectiles, traps and barriers
    bout.gd                frame order, hits, guards, throws and escapes, spirits, rounds, finish
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy
    cpu_controller.gd      the computer opponent, three difficulties
  fighters/
    prototype_rect.gd      the shared kit, as data
    roster.gd              the sixteen fighters and their specials, as a data table
tests/
  selftest.gd              mechanics checks, run only on request
```

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 67 checks. This prototype adds checks for:

- **Exclusive guards:** plain guard doesn't stop a spirit, and spirit guard doesn't stop an ordinary attack.
- **Two Heavens** passing both guard heights.
- **Tomoe's wheel** striking behind.
- **Effects:** armour not interrupting the oni's drink, Musashi's and Hanzō's counters, frost slowing, the web pulling.
- **Air specials:** allowed only where marked.
- **The roster:** sixteen fighters, eight of each kind, two recharging specials each, every special completing.
- **Binding:** recording the chosen special.

The checks confirm the rules behave as written. They cannot tell you whether the game feels good or is balanced.
