# Shikigami (working title)

A 2D fighting game set in a fantasy Japan, in the lineage of Street Fighter and Mortal Kombat. You take a fighter through a gauntlet of rivals of your own kind, then of the other kind, then of monsters too large to fight on equal terms. Opponents of the other kind can be sealed with a finisher and bound as spirits, which you summon in later fights.

The guiding principle: **the fighting is the game; the campaign exists to produce unusual fights.** There are no levels, stat sheets or grinding.

This repository contains Prototype 8: sixteen humans and yokai, still drawn as rectangles, each with two specials from its legend; the human campaign with its spirit captures; combos; a Hard computer; and a computer-against-computer tournament for balance. Everything below the "Prototype 8" heading describes that code. Everything above it describes the design.

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
| Sasaki Kojirō | human | Swallow Cut: Tsubame Gaeshi, an arc covering above and ahead; also in the air | Drying Pole: a thrust of exceptional reach with his overlong nodachi |
| Tomoe Gozen | human | Naginata Wheel: a full circle, front and back; also in the air | Naginata Sweep: a long low sweep that knocks down |
| Benkei | human | Standing Death: advances with armour, after his death standing on the bridge | Seven Weapons: a long-reach grapple, slow to recharge |
| Hattori Hanzō | human | Kawarimi: a counter; struck, he vanishes and strikes from behind | Shuriken: a fast, light projectile; also in the air |
| Buddhist monk | human | Meditation: long, exposed, then restores health | Sutra Palm: a strike that drives the opponent far back |
| Shinto miko | human | Ofuda: a thrown paper talisman | Warding Seal: a talisman laid on the ground ahead; whoever steps on it is held for a second |
| Onmyōji | human | Paper Birds: shikigami released low that climb gently as they fly | Five-Element Seal: a barrier that stops projectiles and repels whoever walks in |
| Shuten-dōji | yokai | Sake: a long, exposed drink that restores health | Kanabō Quake: the club driven into the ground, a low quake to both sides that knocks down; jump it or guard low |
| Kitsune | yokai | Fox Step: vanishes and reappears behind to strike | Foxfire: kitsune-bi, a projectile |
| Tengu | yokai | Gale Fan: a gust that hurls more than it hurts | Flight: a gliding overhead strike; also in the air |
| Kappa | yokai | Sumo Grab: kappa challenge travellers to sumo; slow to recharge | Water Jet: from the dish on its head, a low projectile |
| Yuki-onna | yokai | Frost Breath: short range; slows whoever it touches | Icicle: falls from above some way ahead, an overhead |
| Jorōgumo | yokai | Web: a strand that reels the victim in | Ceiling Drop: up out of reach and down on top of you |
| Nekomata | yokai | Pounce: a leaping overhead | Twin Tails: two tails, low and mid at once |
| Tanuki | yokai | Belly Drum: hara-tsuzumi, a low shockwave to both sides | Leaf Disguise: a counter; a leaf on the head and it is a statue that strikes back |

Every fighter also shares a kit: six normals, a throw, two dashes, a rush (toward + special), a rising anti-air (down + special), the summon gesture, and the finisher. Their proportions (size, speed, health, power, tempo) differ.

### Spirits in combat

- **The spirit's chosen special.** Summoning makes a translucent copy of the bound fighter, which performs the special you chose when you bound it, then vanishes. The copy has no hurtbox or pushbox, but otherwise behaves as the fighter would: a fox steps behind your opponent; a Jorōgumo's web reels them in. Effects a fighter gives itself (healing, armour) go to you, the summoner. No new animation is needed for any pairing, so art cost grows linearly with the roster.
- **Two slots.** Spirit summons the first, down + spirit the second. Each has its own recharge; a slot that is recharging does nothing, and never falls through to the other.
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
3. **Monster tier (1–2 fights).** Huge bosses under modified rules (below).

The run is saved before every fight, including the random generator's state, so it resumes exactly.

**Unlocks.** The campaign starts with the humans. Completing it unlocks all the yokai, for a yokai campaign (the same structure seen from the other side) and for versus.

**Rising difficulty** (planned). Later opponents should be harder through some mix of more health, faster play and a better computer. The tiers already make this a matter of a table keyed by fight number.

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
7. **Balance by play,** guided by the tournament, then rising difficulty through the campaign.
8. **Monsters.** The engine work above, then Ushi-oni.
9. **Art** for a first handful of fighters.
10. **Presentation.** Menus, sound, story between fights.

### Open questions

- **Balance.** The tournament (below) shows which kits the computer wins with. That is evidence, not a verdict: a kit the computer uses badly will look weak whatever its strength. Several specials need play, especially Two Heavens, the counters and the traps.
- **Cancels.** Should normals cancel into specials on hit, for longer combos?
- **Rising difficulty.** The right mix of health, speed and computer skill for later opponents.

---

## Prototype 8

### Running

Open the folder in Godot 4.3+ and press Play, or run `godot --path .` from the command line.

| Screen | Keys |
|---|---|
| Menu | 1 new run, 2 continue run, 3 versus, 4 calibrate timing, 5 computer difficulty, 6 game speed, 7 player 1 invincible, 8 unlock the yokai for practice |
| Fighter select | A / D or arrows to move, Enter or J to begin; locked fighters are marked |
| Run | play; when a beaten opponent stands dazed, perform the finisher shown on screen |
| After a capture | a number to take that spirit, or the last number to release; then, if slots are full, 1 or 2 to replace, 3 to release |
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

- Names are shown over the fighters, and effects are announced there: "+120", "ARMOUR", "COUNTER", "SLOWED", "HELD".
- A heal glows green, armour shows a gold outline, and slow a blue tint.
- Combos are counted under the health bar of the fighter landing them.
- Under each health bar are four recharge boxes: your two specials, then your two spirits.

### What changed

- **Binding.** One choice screen for every capture, always with a release option.
- **The run.** Two tiers of four; the second fight's spirit is granted, and later ones are captured with the finisher.
- **Unlocks.** Completing a run unlocks the yokai. Menu option 8 unlocks them early for practice.
- **Kanabō** is now a low quake to both sides. **Sake** heals and nothing more. **Paper birds** fly lower and flatter. **The warding seal** holds instead of hurting.
- **Counter-stance spirits** answer for their summoner.
- **Combos:** scaling, juggle limit, knockdown and wake-up rules as described above.
- **A Hard computer.** It anti-airs jumpers, punishes moves still recovering within its reach, and uses heals, counters and traps when they fit, besides guarding better. All levels share this logic; the tables differ.
- **Rounds can have a time limit.** The game doesn't use one yet; the tournament does.
- **Balance numbers.** A few were adjusted this round:
  - Benkei's grapple and the kappa's grab recharge more slowly, and the kappa's grab is slower and does less damage.
  - Benkei and Shuten-dōji are a little faster.
  - Shuten-dōji and the nekomata have more health.
  - The kappa has health 900 and power 1.0, down from 1000 and 1.1 (see below).
- **Computer fixes found by the tournament.**
  - The computer and the practice dummy now judge guard height from what is actually coming, including a projectile in flight. They used to judge from the thrower's motion, so the kappa's low water jet was guarded standing every time.
  - A teleport now counts as reaching any distance.

### Balance tournament

```
godot --headless --path . --script res://tests/tournament.gd -- [bouts] [level] [spirits]
```

The tournament plays every fighter against every other with the same computer on both sides (default Hard), in both positions, with 60-second rounds. It prints each fighter's overall win rate and the most lopsided pairings.

Read the results as evidence about this computer with each kit, not as a measurement of balance. A kit that relies on things the computer does poorly will look weak whatever its strength. It runs only when invoked; a run of 480 bouts takes about two minutes, and each run also saves its win matrix so runs with different seeds can be pooled.

**What it has shown so far** (Hard computer, no spirits):

- **The kappa won 92% of its bouts.** Part of that was the guard-height misread above; after the fix it still won 81% over 540 bouts.
  - Changing one property at a time showed that its small body mattered most. At normal size it won 65%. Its damage, its grab and its water jet each contributed less.
  - Kappa are child-sized in legend, so rather than enlarge it, it now pays for being small in health and power, as the nekomata does. With that change it won 52% in the probe and 48% in the next full run.
- **After that change no fighter stands out alone.** A single run gives each fighter 60 bouts, enough to see only large effects: individual win rates there carry about ±12 points of noise.
- **Two patterns recur across runs and are worth watching:**
  - Shuten-dōji is at or near the bottom every time, at about a third of bouts won.
  - Humans as a group win more than yokai, by roughly 10 points.

  Either may be a weakness in how the computer plays slow fighters and those relying on heals, teleports or projectiles, or a real gap. Play is the test.

### Self-test

```
godot --headless --path . --import          # once, to build the class cache
godot --headless --path . --script res://tests/selftest.gd
```

There are 75 checks. This prototype adds checks for:

- combo scaling, the juggle limit and wake-up invulnerability;
- a counter-stance spirit answering for its summoner;
- the seal's hold;
- round time limits;
- captures from one's own kind, including release;
- the run's granted and captured spirits;
- the quake (standing foes knocked down, low guard and jumping avoid it);
- two Hard computers fighting;
- the full-guard dummy guarding a low projectile in flight.

The checks confirm the rules behave as written. They cannot tell you whether the game feels good or is balanced.
