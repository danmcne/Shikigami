# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a fighter through rivals of your own kind, then the other kind, then a giant. Opponents you can bind are sealed with a finisher and become spirits you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This is version 12: sixteen humans and yokai and three giants, still drawn as rectangles. History is in [CHANGELOG.md](CHANGELOG.md), and the first art and audio direction is in [docs/art_and_audio.md](docs/art_and_audio.md).

## Running

Open the folder in Godot 4.3 or later (tested on 4.4.1) and press Play, or run `godot --path .`.

| Screen | Keys |
|---|---|
| Menu | 1 new run, 2 continue run, 3 versus, 4 calibrate timing, 5 computer difficulty, 6 game speed, 7 player 1 invincible, 8 unlock the yokai for practice, 9 tournament |
| Fighter select | A / D or arrows to move, Enter or J to begin |
| After a capture | a number to take that spirit, or the last number to release; then, if slots are full, 1 or 2 to replace, 3 to release |
| Versus | F2 player 2: human / dummy / computer; F3 dummy behaviour; F5 restart; F6 / F7 change fighters (F7 also reaches the giants) |
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

Each player's full move list is on screen in that player's own keys, and it follows facing.

## Fighting

- **Normals** are light or heavy, from standing, crouching (lows) or jumping (overheads).
- **Specials** are special alone or with a direction:
  - special alone: the fighter's first special;
  - away + special: their second;
  - toward + special: the shared rush;
  - down + special: the shared rising anti-air.

  A fighter's own specials recharge after use. Some can be used in the air. There are no rolling motions.
- **Throws** are light+heavy, and beat guard. Pressing light+heavy within 10 frames of being grabbed escapes, and a guarding player may simply press heavy.
- **Dashes:** double tap toward or away. **Crawl:** crouch and walk.
- **Guard** (light+special, held) stops the opponent's own attacks. **Spirit guard** (light+spirit+special) stops spirits' attacks instead; neither stops what the other does.
  - **Heights.** Standing guard stops mid and overhead attacks; crouching guard stops mid and low. A few attacks strike high and low at once, and no guard height stops them.
  - **The cost.** While guarding you can shuffle and crouch, but not attack.
- **Armour** (Benkei's stance) takes damage without being interrupted. **Counters** (Musashi, Hanzō, the tanuki) answer a strike, but not a throw.
- **Combos.** Hits chain while the opponent can't act, shown as "N HITS".
  - Each hit after the first does 10% less damage, down to 30%.
  - A fighter in the air can be juggled up to three hits.
  - A fighter lying down can't be hit, and is invulnerable for a fifth of a second on rising.
- **Timing.** Two presses count as "together" within a per-player window, which menu option 4 measures on the game's real chords.

## Fighters

Eight humans and eight yokai. Each shares a kit of normals, a throw, dashes, the rush and the rising anti-air. Each adds two specials drawn from legend, and has its own proportions: size, speed, health, power and tempo.

| Fighter | Kind | Special | Away + special |
|---|---|---|---|
| Miyamoto Musashi | human | Two Heavens: high and low at once | Void Stance: a counter |
| Sasaki Kojirō | human | Swallow Cut: an arc above and ahead; also in the air | Drying Pole: the longest thrust in the roster |
| Tomoe Gozen | human | Naginata Wheel: front and back; also in the air | Naginata Sweep: a long low sweep that knocks down |
| Benkei | human | Standing Death: advances with armour | Seven Weapons: a long-reach grapple |
| Hattori Hanzō | human | Kawarimi: a counter that reappears behind the attacker | Shuriken: fast and light; also in the air |
| En no Gyōja | human | Meditation: long and exposed; restores 220; 20 s to recharge | Sutra Palm: drives the opponent far back |
| Izumo no Okuni | human | Ofuda: a thrown talisman | Warding Seal: a talisman on the ground ahead that holds whoever steps on it |
| Abe no Seimei | human | Paper Birds: shikigami that climb as they fly; also in the air | Five-Element Seal: a barrier that stops projectiles and repels |
| Shuten-dōji | yokai | Sake: long and exposed; restores 260; 25 s to recharge; a hit spills it | Kanabō Quake: a low quake to both sides that knocks down |
| Kitsune | yokai | Fox Step: vanishes and reappears behind to strike | Nine Tails: a sweep low and mid at once |
| Tengu | yokai | Gale Fan: a gust that hurls more than it hurts | Flight: a gliding overhead; also in the air |
| Kappa | yokai | Sumo Grab: a long-reach throw | Water Jet: a low projectile |
| Yuki-onna | yokai | Frost Breath: short range; slows | Icicle: falls from above some way ahead |
| Jorōgumo | yokai | Web: reels the victim in | Ceiling Drop: up out of reach, then down on you |
| Rokurokubi | yokai | Long Neck: her head arcs out and comes down far away; it is part of her, so a blow to it hurts her and snaps it back | Lantern: thrown in an arc; leaves a small fire where it lands or strikes |
| Tanuki | yokai | Belly Drum: a low shockwave to both sides | Leaf Disguise: a counter, as a statue |

The three named humans come from history and legend:

- **En no Gyōja,** the founder of Shugendō, the mountain asceticism of the yamabushi. He bound the oni Zenki and Gōki into his service.
- **Izumo no Okuni,** a shrine maiden of Izumo, began kabuki.
- **Abe no Seimei** is the most famous onmyōji, known for his shikigami.

## Spirits

**Binding.** Humans bind yokai spirits and yokai bind humans; neither binds its own kind. After the deciding round, if the beaten opponent has something you could take, they stand dazed and your finisher captures it:

- from the other kind, their own spirit, performing whichever of their two specials you choose;
- from your own kind, one of the spirits they carry.

Spirits you already hold are never offered, and every capture can be released.

**Summoning.** You carry two spirits: spirit summons the first, down + spirit the second. A spirit is a translucent copy of its source, with no hurtbox, that performs its chosen special and vanishes.

- **For you.** What the source would give itself goes to you: a sake spirit heals you.
- **Counters.** A counter-stance spirit wraps you, and answers for you if you're struck.
- **Recharge.** Each slot recharges, never faster than the special it performs. A recharging slot does nothing; it never falls through to the other slot.

## Campaign

A run is nine fights:

1. **Four of your own kind.** They carry 0, 1, 2 and 2 spirits of the kind you can bind. The second opponent's spirit is simply yours when you win. From the third and fourth you capture one of theirs with the finisher.
2. **Four of the other kind,** again carrying 0, 1, 2 and 2. Your finisher seals the opponent itself.
3. **A giant,** at random.

You never fight your own fighter, nor anyone twice. The run is saved before every fight, and menu option 2 resumes it exactly. The campaign begins with the humans; completing it unlocks the yokai for their own campaign and for versus.

## Giants

Giants are not fighters with big health bars. Each is a different spatial problem built on the same combat:

- **Ushi-oni:** its body and positioning.
- **Gashadokuro:** enormous spatial structure.
- **Nue:** an enemy in the air.

Shared rules:

- **Arena.** One long round in a circular arena two stage-lengths round, with no walls. Run far enough one way and you come back round the other. The view follows you, and pillars mark the way.
- **Parts.** A giant's body is several parts; every hit lands on one, scaled by it (a shell takes less, a weak point more). Breaking some parts staggers or cripples it. Some parts can be struck only while an attack exposes them. Giants don't flinch, can't be shoved, thrown or bound, and some can be climbed and ridden.
- **Telegraphs.** Every attack's start-up shows in red where it will land. Pieces with a start-up of their own, such as lightning, mark the floor first. Falling things and flying giants cast shadows.
- **Sealing.** A beaten giant must be sealed. It lies dazed with its core glowing; land the finisher within the window or the core reforms with a quarter of its health and the fight goes on. Sealing a giant earns nothing.
- **Pace follows difficulty:**

  | Setting | Turning delay | Rest | Wind-up | Travel speed | Volley spread | Seal window |
  |---|---|---|---|---|---|---|
  | Practice | ×3 | ×2 | ×1.5 | ×0.7 | ×1.5 | 10 s |
  | Easy | ×2 | ×1.6 | ×1.3 | ×0.8 | ×1.35 | 7.5 s |
  | Normal | ×1 | ×1 | ×1 | ×1 | ×1 | 5 s |
  | Hard | ×0.85 | ×0.85 | ×1 | ×1 | ×0.95 | 5 s |

### Ushi-oni

The ox-headed, spider-bodied shore demon fills a third of a stage.

- **Body.** Its shell takes half damage. Low attacks break its legs; once crippled it walks at half speed, can't stomp, and breathes more poison. Its head takes double damage but is open only after a charge.
- **Climbing.** Jump onto its head, then its back. Ride it, strike the shell beneath you, or drop off behind it. It turns round after a delay and bucks riders off.

| Attack | Answer |
|---|---|
| Leg Stab, both sides | guard |
| Stomp, a low quake | jump, or guard low |
| Charge across the arena, passing through you | jump it, or ride it |
| Poison Breath, which slows | guard |
| Buck, used only on riders | jump off, or guard |

### Gashadokuro

The giant skeleton looms behind the arena with no body to bump into.

- **Facing.** In this fight you turn by input, not to face it: hold back to turn round and run. A quick back + special and the backdash still work. Guard covers only the side you face.
- **Hands.** It doesn't turn, so its left and right hands are yours, and it drifts to keep you under one. Its hands start half a stage out from its centreline and stop under its skull.
- **Openings.** Nothing of it can be struck at rest: a hand lies open after a slam, and the skull stays low after a bite.

| Attack | Answer |
|---|---|
| Left / Right Slam, the hand on your side, an overhead | step out, or guard standing; then strike the open hand |
| Skull Bite, at its centre | step out; then strike the skull, for double damage |
| Left / Right Grab, a hand along the floor | be out of reach, or face it and guard; you are pushed unhurt beneath the skull and must clear the unguardable jaws. Caught, you are carried there and chewed |
| High / Low Clap, both hands meeting beneath it; guarding one pushes you into the other | crouch under the high, jump the low |
| Bone Rain, three bones with narrow gaps (more often once a hand is broken) | stand in a gap, or guard standing |

A broken hand takes its slam and grab with it, and ends the claps.

### Nue

Monkey face, tanuki body, tiger limbs, snake tail, on a black thundercloud.

- **Reaching it.** It flies just above an ordinary jump's reach. You can hit it with:
  - the rising anti-air or Kojirō's Swallow Cut;
  - projectiles that climb (Seimei's paper birds) or are thrown from the top of a jump (Hanzō's shuriken);
  - a punish on the ground after it dives;
  - Tengu, who jumps high enough to touch the cloud.
- **Riding.** On the ground its back can be stood on and crossed. Stay on when it takes off and it carries you up, then thrashes to throw you.
- **Grounded.** Break its thundercloud and it falls for good, fighting on as a beast.

| Attack | Answer |
|---|---|
| Lightning: three marked spots, then bolts | stand between them, or guard |
| Dive, an overhead | step aside or guard standing; then strike it on the ground |
| Tail Strike, down behind it | don't loiter beneath it |
| Thrash, used only on riders | jump off, or guard |
| Grounded: Claw / Tail Lash (low, both sides) / Pounce | guard / guard low or jump / guard |

## Healing

Shuten-dōji's sake and En no Gyōja's meditation are long, exposed actions. They restore a great deal and recharge very slowly, with recharges reset each round, so healing is a decision made once or twice a round. A hit during either spills it, and the recharge is spent anyway.

## The computer

Four levels: Practice (the default), Easy, Normal and Hard. All levels share one logic driven by a table of numbers. It knows nothing about particular characters: it chooses among a fighter's own moves by reach and enters them as a player would. Hard anti-airs, punishes moves that are still recovering, and uses heals, counters and traps when they fit. Every level heals only at safe moments.

## Practice options and calibration

- **Options.** Menu options 5–8 set the computer's difficulty, game speed (100%, 75% or 50%, everything slowed together), player 1 invincibility, and an early yokai unlock.
- **Calibration.** Menu option 4 measures each player's chord window. It runs five tries each of throw, guard, spirit guard, toward+special, down+spirit, and two quick separate presses, then places the window between the widest "together" and the narrowest "separate".

## Balance tournament

From the menu (9), or from the command line, with or without a window:

```
godot --headless --path . -- --tournament [--bouts=N] [--level=N] [--seed=N] [--spirits]
```

It plays every fighter against every other with the same computer on both sides, and reports:

- win rates with 95% margins;
- the human and yokai averages;
- the most lopsided pairings;
- how often each special is used, and health restored per bout.

Results are also saved to `user://tournament_report.txt`. They describe this computer playing each kit: evidence about balance, not a measurement of it. Use them to find outliers, then check those in play.

## Design notes

- **Roster.** Playable fighters are roughly person-sized and fit the ordinary fighting-game space; giants are encounters of another kind. The roster grows, or changes, only for a genuinely new mechanic, since with spirits every fighter multiplies the combinations. Rokurokubi replaced the nekomata on those grounds: an exposed reach, and a cat-like kit too close to the kitsune.
- **Data.** Fighters and giants are data; no code refers to a character by name.
- **Frames.** Combat runs in frames at a fixed 60 Hz, with rectangular boxes separate from the art.
- **No online play,** so the simulation isn't bit-deterministic.

## Roadmap

1. Balance by play, guided by the tournament.
2. Rising difficulty through the campaign: health, speed and computer skill by fight number.
3. Art, then sound and music (direction in `docs/art_and_audio.md`).
4. Presentation: menus, story between fights.

## Open questions

- Should the own-kind tier's first fight also reward something?
- Should normals cancel into specials on hit, for longer combos?
- What mix of health, speed and computer skill should make later opponents harder?

## Structure

```
project.godot, main.tscn
game/
  main.gd                  screens and flow
  run.gd                   a run as pure state: tiers, captures, the giant; save and restore
  tournament.gd            computer-against-computer tournament
  calibration.gd           the per-player chord window
  settings.gd              timing, options, unlocks, the saved run
  controls_text.gd         command patterns -> the keys a player presses
  input_setup.gd           key and gamepad bindings
  views/bout_view.gd       drawing: fighters, giants, telegraphs, pieces, HUD
  combat/
    move_definition.gd     frame data, boxes and every move effect
    fighter_definition.gd  a fighter as data
    spirit_binding.gd      a bound spirit and its chosen special
    monster_definition.gd  a giant as data: parts, attacks, movement, arena
    monster.gd             a giant in a bout
    command.gd, input_history.gd, intent.gd
    fighter.gd             per-fighter state machine; spirits and giants are fighters too
    entity.gd              projectiles, traps, hands, heads, lanterns, fire
    bout.gd                one bout: frame order, hits, guards, throws, spirits, combos, arenas, rounds, sealing
  controllers/             player, training dummy, computer
  fighters/                the shared kit and the sixteen fighters
  monsters/                Ushi-oni, Gashadokuro, Nue
docs/art_and_audio.md      art and audio direction
tests/selftest.gd          mechanics checks, run only on request
```

## Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 114 checks. They cover:

- **The rules:** guards, throws, combos, commands, timing.
- **Every fighter's specials:** each one completes.
- **Spirits, binding and the campaign,** including no repeats.
- **The giants,** and **the computer, calibration and tournament.**

They confirm the rules behave as written, not that the game feels good or is balanced.
