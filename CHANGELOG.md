# Changelog

Newest first. The README describes the current version only.

## 13

- **The art test.** Musashi and Shuten-dōji are cut-paper puppets:
  - poses come from state, and attacks aim the weapon arm at the move's own hitboxes;
  - two faces each (teru and kumoru);
  - tori and uke colourways.

  The shore at dusk is the first ukiyo-e backdrop, under a washi grain over the screen. The computer wears tori in the campaign; player 2 wears uke in versus, so Shuten-dōji is a red oni or a blue one.
- **Fox Step** recharges in 4 s, up from 2. Recharges were never shortened on Hard; the Hard computer simply uses Fox Step the moment it's ready.
- **The Drying Pole** wounds only with its tip, at reach 140–260. Too close, it passes harmlessly and is spent.
- **Yokai names:** Tamamo-no-Mae, Sōjōbō, Kawatarō, O-Yuki, Danzaburō-danuki.
- **Tools:** `tests/shot.gd` renders posed scenes for art review.

## 12.1

- **Rokurokubi's head.** It stays joined to her by a neck, drawn even in the rectangle version. It turns back when it strikes or when it comes down to a fighter's mid-height, never into the ground. It returns along the path it took, harmless on the way back but still part of her.
- **Engine:** returning pieces, which turn back on striking or at a set height and retrace their path.
- **Art direction:** two faces per fighter, after the noh mask's change of expression with its angle.

## 12

- **Giant arenas.** Every giant is fought in a circular arena two stage-lengths round, so none can corner you. Ushi-oni and Nue keep ordinary facing and turn to meet you after their delay. Only attacks that reach past a monster's back edge are used against someone behind it, so Ushi-oni no longer charges away from you.
- **Riding Nue.** Its back can be stood on, crossed, and ridden up into the air. Riders are now carried vertically as well as horizontally. A new Thrash attack throws riders off. Its pushbox was lowered below its back so that landing there isn't blocked.
- **Campaign.** You never fight your own fighter, nor anyone twice; this survives saving and resuming.
- **Rokurokubi replaces the nekomata.**
  - Long Neck: her head arcs out and comes down far away. It stays part of her, so a strike on it hurts her and withdraws it.
  - Lantern: thrown in an arc; it leaves a small fire where it lands or strikes.
- **The kitsune** keeps Fox Step and takes Nine Tails, a low-and-mid tail sweep, in place of Foxfire.
- **Names.** The monk is En no Gyōja, the miko Izumo no Okuni, the onmyōji Abe no Seimei.
- **Engine:**
  - pieces that arc (velocity and gravity) and end on reaching the ground;
  - tethered pieces, struck as part of their performer and withdrawn when the move ends;
  - pieces that leave another piece behind;
  - pieces created from a position and facing.
- **Docs.** The history moved here from the README. A first art and audio direction is in `docs/art_and_audio.md`.

## 11

- **Nue**, the third giant, and the flight capability it needs.
- **Free facing** turns only by holding back; the double tap of back is the backdash again.
- **Gashadokuro's arena** is two stage-lengths round, down from three. Bone rain can come before any hand is broken.
- **Monster pace.** On Easy and Practice, monsters wind up longer, send things more slowly, and rest longer between attacks.
- **Telegraphs.** Pieces with a start-up of their own (lightning) mark the floor before they strike. Flying monsters cast shadows.

## 10.2

- **Gashadokuro's hands** start half a stage out from its centreline and stop beneath its skull. Sweeps became grabs with the jaws to follow, and claps push a guard into the other hand.
- **Free facing** in its fight, with turning by input and guard covering the side you face.
- **Circular arena** three stage-lengths round, with a following camera.
- **Giants must be sealed**, or their core reforms with a quarter of their health.
- **Bone rain** spreads wider on Practice and Easy.
- **Engine:** converging, grabbing and pushing pieces; follow-up attacks; monster cores; the arena wrap.

## 10.1 (delivered as "10")

- **Gashadokuro:** left and right hands, half-stage walls, high and low claps, staggered bone rain.
- **Spawning:** multi-piece spawns and spawn origins.
- **Fix:** a body without a pushbox blocks nothing.

## 10

- **Gashadokuro** introduced.
- **Monster pace** follows difficulty.
- **Yuki-onna:** more health, quicker frost breath.

## 9

- **Monster engine and Ushi-oni:**
  - climbable and rideable;
  - slow turning and a buck;
  - can't be shoved.
- **Teleports** land beyond a body's far edge.
- **Kojirō:** longer Drying Pole.
- **Healing:** slow, strategic heals; the computer heals at safe moments.
- **Spirits:** a spirit's recharge is never shorter than its special's.
- **Tournament:** in the game and on the command line.

## 8

- **Human campaign:** a granted spirit, then captures with the finisher; completing it unlocks the yokai.
- **Combo rules:** damage scaling, the juggle limit, wake-up invulnerability.
- **Spirits:** counter-stance spirits.
- **Balance:**
  - a Hard computer;
  - the balance tournament;
  - the kappa rebalanced after its small body proved its biggest advantage.

## 7

- **Roster:** sixteen named fighters with two specials each.
- **Effects:** armour, counters, slow, high-and-low strikes, air specials.
- **Guards:** exclusive spirit guard.
- **Binding:** chooses a special.
- **Finisher:** one input for everyone.
- **Monsters:** first planning.

## 6

- **Specials:** signature specials with recharge.
- **Spirits:** perform signatures.
- **Guards:** spirit guard.
- **Campaign:** tiers by kind; save and resume.
- **Inputs:** rolling motions dropped.

## 5

- **Guard:** the light+special chord.
- **Calibration:** covers every chord.
- **Options:** difficulty levels, game speed, invincibility.

## 4

- **Defence:** a guard button and crawling.
- **Inputs:** per-player chord calibration.
- **Kinds:** humans and yokai.
- **Spirits:** throws.
- **Finishers.**
- **Computer and run:** an easy computer and the first run mode.

## 3

- **Spirits:** summoning and cooldowns.
- **Throws:** escape.
- **Fighters:** three archetypes; move lists in real keys.

## 2

- **Inputs:** four-button layout and command notation.
- **Moves:** dashes, specials, throws, projectiles, knockdown, invulnerability.

## 1

- **Two rectangles:** movement, guard, light and heavy attacks, rounds.
