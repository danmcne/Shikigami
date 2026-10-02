# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a fighter through a gauntlet of rivals of your own kind, then of the other kind, then of monsters too large to fight on equal terms. Opponents of the other kind can be sealed with a finisher and bound as spirits, which you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository contains Prototype 10: sixteen humans and yokai and two monsters, Ushi-oni and Gashadokuro, still drawn as rectangles; the full human campaign ending in a monster fight; combos; a computer at four difficulties; and a balance tournament runnable from the game or the command line. Everything below the "Prototype 10" heading describes that code. Everything above it describes the design.

## The design

### Kinds and binding

Every fighter is a **human** or a **yokai**. Humans bind yokai spirits; yokai bind human spirits; neither binds its own kind.

After winning the deciding round, if the beaten opponent has something you could take, they stand dazed for five seconds. If your finisher connects, you take it. The finisher input is the same for everyone (away, toward + spirit); each fighter has its own way of performing it. What can be taken:

- **From an opponent of the other kind:** their own spirit, performing whichever of their two specials you choose.
- **From an opponent of your own kind:** one of the spirits they carry. Their own powers are your kind and can't be bound.

Spirits you already hold are never offered. Each capture is a choice: take one of what is offered, or release it all. If both slots are full, you then choose which spirit to give up, or you can release the new one.

### The roster

Eight humans and eight yokai. Each has two specials: one on special, one on away + special. Each special recharges after use. The specials are drawn from legend.

| | Kind | Special | Away + special |
|---|---|---|---|
| Miyamoto Musashi | human | Two Heavens: one sword high, one low, at once; no single guard height stops it | Void Stance: a counter; struck during it, he cuts back |
| Sasaki Kojirō | human | Swallow Cut: Tsubame Gaeshi, an arc covering above and ahead; also in the air | Drying Pole: a thrust of exceptional reach with his overlong nodachi, the longest strike in the roster |
| Tomoe Gozen | human | Naginata Wheel: a full circle, front and back; also in the air | Naginata Sweep: a long low sweep that knocks down |
| Benkei | human | Standing Death: advances with armour, after his death standing on the bridge | Seven Weapons: a long-reach grapple, slow to recharge |
| Hattori Hanzō | human | Kawarimi: a counter; struck, he vanishes and strikes from behind | Shuriken: a fast, light projectile; also in the air |
| Buddhist monk | human | Meditation: long and exposed, restores a great deal, very slow to recharge | Sutra Palm: a strike that drives the opponent far back |
| Shinto miko | human | Ofuda: a thrown paper talisman | Warding Seal: a talisman laid on the ground ahead; whoever steps on it is held for a second |
| Onmyōji | human | Paper Birds: shikigami released low that climb gently as they fly | Five-Element Seal: a barrier that stops projectiles and repels whoever walks in |
| Shuten-dōji | yokai | Sake: a long, exposed drink that restores a great deal; very slow to recharge, and a hit spills it | Kanabō Quake: the club driven into the ground, a low quake to both sides that knocks down; jump it or guard low |
| Kitsune | yokai | Fox Step: vanishes and reappears behind to strike | Foxfire: kitsune-bi, a projectile |
| Tengu | yokai | Gale Fan: a gust that hurls more than it hurts | Flight: a gliding overhead strike; also in the air |
| Kappa | yokai | Sumo Grab: kappa challenge travellers to sumo; slow to recharge | Water Jet: from the dish on its head, a low projectile |
| Yuki-onna | yokai | Frost Breath: short range; slows whoever it touches; quick to recharge | Icicle: falls from above some way ahead, an overhead |
| Jorōgumo | yokai | Web: a strand that reels the victim in | Ceiling Drop: up out of reach and down on top of you |
| Nekomata | yokai | Pounce: a leaping overhead | Twin Tails: two tails, low and mid at once |
| Tanuki | yokai | Belly Drum: hara-tsuzumi, a low shockwave to both sides | Leaf Disguise: a counter; a leaf on the head and it is a statue that strikes back |

Every fighter also shares a kit: six normals, a throw, two dashes, a rush (toward + special), a rising anti-air (down + special), the summon gesture, and the finisher. Their proportions (size, speed, health, power, tempo) differ.

### Spirits in combat

- **The spirit's chosen special.** Summoning makes a translucent copy of the bound fighter, which performs the special you chose when you bound it, then vanishes. The copy has no hurtbox or pushbox, but otherwise behaves as the fighter would: a fox steps behind your opponent; a Jorōgumo's web reels them in. Effects a fighter gives itself (healing, armour) go to you, the summoner. No new animation is needed for any pairing, so art cost grows linearly with the roster.
- **Two slots.** Spirit summons the first, down + spirit the second. Each has its own recharge, never shorter than that of the special the spirit performs, so a bound sake spirit can't heal you more often than the oni itself drinks. A slot that is recharging does nothing, and never falls through to the other.
- **Counter stances as spirits.** Summoning a counter-stance spirit wraps you in it for the stance's duration. If you are struck in that time, the hit doesn't land: the spirit steps out of you and answers, from where you stand. Throws aren't countered.

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
- **Armour** (Benkei's stance) takes damage without being interrupted. Throws ignore armour.
- **Counters** (Musashi, Hanzō, Tanuki) are beaten by throws and by waiting them out.

### Combos

Hits can chain while the opponent can't act.

- **Counted hits.** Consecutive hits on a fighter who hasn't recovered form a combo, shown as "N HITS".
- **Damage scaling.** Each hit after the first does 10% less, down to 30%, so long chains reward skill without being lethal by themselves.
- **Juggles.** A fighter in the air can be hit again, including one knocked down and still falling. After three hits in the air they can't be hit until they land.
- **Knockdowns.** A fighter lying on the ground can't be hit. On getting up they are invulnerable for 12 frames, a fifth of a second, so they can't simply be kept down.

There are no cancels yet: chains come from links and juggles. Cancelling a normal into a special on hit is the obvious next step if longer chains are wanted.

### Timing

Two presses count as "together" if they land within a short window. Keyboards, pads and hands differ, so each player calibrates the window on the game's real chords:

- throw, guard and spirit guard on one hand;
- direction + button across both hands;
- quick deliberate sequences that must stay separate.

### Campaign

A run is a single climb through three tiers. Opponents are shuffled within each tier, and you don't fight every member.

1. **Own-kind tier, 4 fights.** The opponents carry 0, 1, 2 and 2 spirits of the kind you can bind.
   - The first fight is a plain fight.
   - The second opponent's single spirit is simply yours when you win.
   - From the third and fourth, your finisher captures one of the spirits they carry.
2. **Other-kind tier, 4 fights.** Again 0, 1, 2 and 2 spirits (now of your own kind, which you can't take). Your finisher seals the opponent itself, and you take one of its two specials.
3. **Monster tier.** A fight against a monster (Ushi-oni or Gashadokuro, at random) under its own rules (below).

The run is saved before every fight, including the random generator's state, so it resumes exactly.

**Unlocks.** The campaign starts with the humans. Completing it unlocks all the yokai, for a yokai campaign (the same structure seen from the other side) and for versus.

**Rising difficulty** (planned). Later opponents should be harder through some mix of more health, faster play and a better computer. The tiers already make this a matter of a table keyed by fight number.

### Healing

Two fighters heal: Shuten-dōji's sake and the monk's meditation. Both are long, exposed actions that restore a great deal (260 and 220 health) and recharge very slowly (25 and 20 seconds; recharges reset each round). Healing is therefore a decision made once or twice a round, not a habit. A hit during the drink or the prayer spills it, and the recharge is spent either way.

### Monsters

Monsters are not scaled-up fighters. Each is a bespoke encounter, built from the same frame-based combat. The engine for them exists, and Ushi-oni is the first. Shared rules:

- **One long round**, not best of three.
- **Parts.** A monster's body is several hurtboxes. Every hit lands on a part and costs the monster health, scaled by that part: a shell takes less, a weak point more. Some parts can be broken; breaking one staggers the monster and may cripple it, changing what it can do. Some parts are hidden and can be struck only while an attack exposes them.
- **No flinching.** Monsters take damage without being interrupted, except when a part breaks. Nor can they be shoved: when bodies collide, the fighter gives way.
- **Climbing.** Some parts can be stood on. A fighter lands on them, is carried as the monster moves, and faces the way it walks while on top. Strikes from on top hit the part underfoot. Walking off an edge drops you to the ground.
- **Turning.** A monster turns round only after its opponent has stayed behind it for a while; until then it can use only attacks that reach behind it. It doesn't turn at all while ridden, and some attacks exist only to throw riders off.
- **Teleports** land beyond the far edge of the target's body, so teleporting past a monster puts you behind it rather than inside it.
- **Attacks from the stage edge.** An attack can release its projectile at the stage edge beyond the opponent, travelling back toward the monster: a giant's hand sweeping in from behind you.
- **Pace follows difficulty.** A monster's turning delay and its rest between attacks scale with the difficulty setting:

  | Setting | Turning delay | Rest between attacks |
  |---|---|---|
  | Practice | ×3 | ×1.6 |
  | Easy | ×2 | ×1.3 |
  | Normal | ×1 | ×1 |
  | Hard | ×0.85 | ×0.85 |
- **Telegraphs.** Every attack's start-up is drawn in red where its hitboxes will land, brightening as the attack approaches.
- **Attacks from outside the fighting space.** Hands, tails and lightning arrive from beyond the stage edges or from above.
- **No throws against a boss,** and a boss can't be bound. Spirits work normally against it. Boss strikes are guarded with plain guard, at the usual heights.

| Monster | Legend | Encounter |
|---|---|---|
| Ushi-oni (built) | ox-headed, spider-bodied shore demon | Fills a third of the stage; its shell takes half damage. Leg Stab strikes both sides at once. Stomp is a low quake across the stage. Charge crosses the whole stage at speed, passing through you, and must be jumped. Poison Breath slows. Its legs can be broken with low attacks; once crippled it walks at half speed, can't stomp, and breathes more. Its head takes double damage but is open only after a charge, when it lowers to recover. Its head and back can be stood on: jump onto the head, then up onto the back, ride it, strike the shell, or drop off behind to reach its back legs. It turns round after a second, and Buck throws off riders. |
| Gashadokuro (built) | giant skeleton of the unburied dead | Looms behind the stage with no body to bump into: you walk beneath it, and it drifts to keep you under one hand. Nothing of it can be struck at rest. Hand Slam comes down from above on whoever stands under the hand, an overhead. Far Slam is the other hand, for those who slip past. Skull Bite comes down at its centre. Bone Sweep is a hand sweeping in along the floor from the stage edge behind you. After a slam the hand lies open and can be broken; after a bite the skull stays low, taking double damage. Break a hand and it rains bones from above instead of using that hand. |
| Nue | chimera (monkey face, tanuki body, tiger limbs, snake tail) in a thundercloud; shot down by Minamoto no Yorimasa | Flies around the arena out of normal reach. Lightning strikes marked spots on the floor, the snake tail strikes from behind, and dives are overheads. It is vulnerable when it dives, and to anti-air projectiles. Bringing it down grounds it for a final phase. |
| Ōmukade (candidate) | the giant centipede shot by Tawara Tōda | A segmented body that crosses the stage in waves; segments are parts. |
| Yamata no Orochi (candidate) | eight-headed serpent | Several heads as parts, each with its own attack. |

A monster is data (`MonsterDefinition`):

- parts, each with a box, a damage scale, optional health, and whether it is hidden;
- attacks, each an ordinary `MoveDefinition` with a weight (and a weight once crippled), the distances it is used at, a travel speed, whether it passes through, which hidden parts it exposes, and which parts it needs unbroken;
- walking speed, rest between attacks, and stagger time.

`Monster` interprets the data, so a new monster is mostly a new data file; Gashadokuro needed only edge-spawned attacks beyond what Ushi-oni had. Next: Nue, which needs flight.

### Modes

- **Campaign**, as above.
- **Versus:** any two unlocked fighters, local only.
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
5. **Character.** Sixteen named fighters, two specials each, spirits performing a chosen special, exclusive guards. *Done.*
6. **Campaign and balance tools.** The human campaign's capture structure, unlocks, combos, a Hard computer, and a computer-against-computer tournament. *Done in this repository.*
7. **Monsters.** The engine, Ushi-oni and Gashadokuro. *Done in this repository.* Next: Nue.
8. **Balance by play,** guided by the tournament, then rising difficulty through the campaign.
9. **Art** for a first handful of fighters.
10. **Presentation.** Menus, sound, story between fights.

### Open questions

- **Balance.** The tournament (below) shows which kits the computer wins with. That is evidence, not a verdict: a kit the computer uses badly will look weak whatever its strength. Several specials need play, especially Two Heavens, the counters and the traps.
- **Cancels.** Should normals cancel into specials on hit, for longer combos?
- **Rising difficulty.** The right mix of health, speed and computer skill for later opponents.

---

## Prototype 10

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| Screen | Keys |
|---|---|
| Menu | 1 new run, 2 continue run, 3 versus, 4 calibrate timing, 5 computer difficulty, 6 game speed, 7 player 1 invincible, 8 unlock the yokai for practice, 9 tournament |
| Fighter select | A / D or arrows to move, Enter or J to begin |
| Run | nine fights: four of your own kind, four of the other, then a monster |
| After a capture | a number to take that spirit, or the last number to release; then, if slots are full, 1 or 2 to replace, 3 to release |
| Versus | F2 player 2: human / dummy / CPU; F3 dummy behaviour; F5 restart; F6 / F7 change fighters (F7 also reaches the monsters) |
| Tournament | progress, then results; Esc stops it or returns |
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

### Fighting Ushi-oni

In versus, press F7 until player 2 is Ushi-oni. In a run, it is the ninth fight.

- **Parts.** Its parts are drawn separately. The orange bars under its legs show how close each leg is to breaking, and broken legs turn grey. Its head is an outline until it lowers after a charge, when it lights up.
- **Telegraphs.** Every attack's start-up is drawn in red where it will land, brightening as it approaches.
- **Getting behind it.** Jump onto its head (every fighter's jump clears it), then up onto its back.
  - On its back you are carried as it moves, you face the way you walk, and your attacks hit the shell beneath you.
  - Walk off the back to drop behind it. It turns round about a second later. Until then it can only use attacks that reach behind it: the leg stab and the stomp.
- **Its attacks and their answers:**
  - Leg Stab: guard it.
  - Stomp: jump it or guard low.
  - Charge: jump it, or ride it. It passes through, and then its head is open.
  - Poison Breath: guard it, or be slowed.
  - Buck, used only on riders: jump off when it shows red above its back, or guard.
- **Strategy.** Low attacks break its legs; the head takes double damage. Throws don't work on it, and it can't be bound.

### Fighting Gashadokuro

In versus, press F7 past Ushi-oni. In a run, it may be the ninth fight.

- **What you see.** Its ribs and spine loom faintly behind the stage. Its hands and skull are outlines high above when they can't be struck, and solid bone when they can.
- **Its attacks and their answers:**
  - Hand Slam, on whoever is under its near hand: step out of the red, or guard standing. Then strike the hand while it lies open.
  - Far Slam, on the far side, if you slipped under it: the same answer.
  - Skull Bite, at its centre: step out, then strike the skull while it stays low, for double damage.
  - Bone Sweep, along the floor from the stage edge behind you: jump it, or guard low.
  - Bone Rain, once a hand is broken: guard standing, or keep moving.
- **Moving.** You can walk straight under it; it turns round to follow, after its turning delay.

### Tournament

From the menu (9), or from the command line, with or without a window:

```
godot --headless --path . -- --tournament [--bouts=N] [--level=N] [--seed=N] [--spirits]
```

`--bouts` is bouts per ordered pairing (default 2), `--level` an index into the computer's levels (default 3, Hard), `--seed` the random seed (default 1), and `--spirits` gives every fighter two random spirits. Headless, it prints the results and quits; with a window it shows progress and then the results. Either way the results are also saved to `user://tournament_report.txt`.

The results cover:

- each fighter's win rate, with a 95% margin;
- the human and yokai averages;
- the most lopsided pairings;
- how often each special was used per bout, and how much health was restored per bout.

A run of 480 bouts takes about two minutes. Runs with different seeds are independent and can be averaged.

### What the tournament says now

These are results from the Hard computer playing itself, with the caveats above.

- **Healing.** Before this version the computer almost never healed: it considered it only at a distance a slow oni rarely reaches, and only with a small chance. It now heals at safe moments, at every difficulty:
  - the opponent is knocked down at some distance;
  - the opponent is still recovering for longer than the heal takes;
  - or the opponent is far away with no projectile ready.

  In the latest run the oni drank about once per bout and restored about 95 health per bout. The monk prayed about once per bout and restored about 110. Some attempts are still spilled by hits, as intended.
- **Shuten-dōji** won 38–42% of its bouts across the two runs since, up from about a third before the computer drank. The very slow recharge keeps the sake from making it overpowered.
- **Kojirō** was last or nearly last in every run (28–35%). After his Drying Pole was lengthened (reach 280, start-up one frame faster), he won 47% in the next run.
- **The onmyōji** is usually in the bottom quarter. Hanzō, Tomoe Gozen, Musashi and the miko are usually near the top. In the latest run Yuki-onna won only 20%, against 36–47% before; that may be noise, but it's worth watching.
- **The human/yokai gap** varies between runs, from a few points to about ten in the latest.
- **Noise.** Each run gives a fighter only 60 bouts, so these are patterns to check in play rather than numbers to tune from.

### What changed

- **Gashadokuro**, the second monster (above).
- **Attacks from the stage edge,** a new monster capability.
- **A body without a pushbox now blocks nothing.** Before, a zero-size pushbox still counted as overlapping whatever contained it.
- **Monster pace follows difficulty.** On Easy, Ushi-oni takes twice as long to turn round as on Normal; on Practice, three times.
- **Yuki-onna** has a little more health (950, from 900) and a quicker frost breath (recharges in 1.7 s, from 2 s).
- **From Prototype 9:**
  - Ushi-oni and the monster engine; its head and back can be climbed and ridden; it turns slowly, bucks riders off, and can't be shoved.
  - Teleports land beyond a body's far edge.
  - Kojirō's longer Drying Pole.
  - Slow, strategic heals, and the computer healing at safe moments.
- **Sake and meditation:** big heals, very slow recharge, longer and interruptible. The computer heals at safe moments at every level, Practice included.
- **Spirit recharge** is never shorter than the recharge of the special the spirit performs.
- **Tournament** in the game and on the command line (the old test script is gone).

### Structure

```
project.godot, main.tscn
game/
  main.gd                  screens and flow: menu, select, run, captures, versus, calibration, tournament
  run.gd                   a run as pure state: tiers, captures, the monster fight; save and restore
  tournament.gd            computer-against-computer tournament, run incrementally, with a report
  calibration.gd           measures a player's chord window on the game's real inputs
  settings.gd              timing, options, unlocks and the saved run, in user://settings.cfg
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           all key and gamepad bindings
  views/
    bout_view.gd           draws a bout: fighters, monsters and telegraphs, spirits, projectiles, HUD
  combat/
    move_definition.gd     frame data, damage, height, hitboxes and every move effect
    fighter_definition.gd  kind, stats, boxes, moves, commands, two specials, summon, finisher
    spirit_binding.gd      a bound spirit: source fighter and chosen special
    monster_definition.gd  a monster as data: parts, attacks, movement
    monster.gd             a monster in a bout: parts, staggers, its own behaviour
    command.gd             command notation and priority
    input_history.gd       recent presses and holds, the chord window, command matching
    intent.gd              one frame of what a controller wants; the guard chords
    fighter.gd             per-fighter state machine; spirits and monsters are fighters too
    entity.gd              projectiles, traps and barriers
    bout.gd                frame order, hits on any part, guards, throws, spirits, combos, rounds, finish
  controllers/
    player_controller.gd   InputMap -> Intent
    dummy_controller.gd    training dummy
    cpu_controller.gd      the computer opponent, four difficulties
  fighters/
    prototype_rect.gd      the shared kit, as data
    roster.gd              the sixteen fighters and their specials, as a data table
  monsters/
    ushi_oni.gd            Ushi-oni, as data
    gashadokuro.gd         Gashadokuro, as data
    bestiary.gd            every monster
tests/
  selftest.gd              mechanics checks, run only on request
```

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 93 checks. Prototypes 9 and 10 added checks for:

- Ushi-oni: its hidden head, open after a charge; its charge passing through; damage by part; a broken leg staggering and crippling it; one-round bouts; no throws or binding; using its attacks unprompted.
- Climbing it: onto the head, then the back; every fighter's jump clearing the head; striking from on top; dropping off behind; being carried by its charge; being bucked off; its slow turning; and a teleport landing behind it.
- Monster pace by difficulty.
- Gashadokuro: nothing to strike at rest; a slam hitting whoever is under the hand, which then lies open; the sweep coming from the stage edge behind you; walking beneath it; bone rain once a hand is broken.
- The computer drinking its sake when hurt and safe, at the easiest and hardest levels.
- A spirit's recharge.
- The tournament engine.

The checks confirm the rules behave as written. They cannot tell you whether the game feels good or is balanced.
