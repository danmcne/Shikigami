# Changelog

Newest first. The README describes the current version only.

## 15.4

- **Gashadokuro:**
  - **Errors fixed.** Its ribs were polygons that crossed themselves, so they could not be filled (showing as outlines) and raised about a thousand errors a second. They are now chains of filled bone. Every cut-paper fill now falls back to the shape's hull, so no shape can flood the debugger again.
  - **Duplicate hands fixed.** A sweeping hand outlived its attack, and the arm used to return to rest with a second hand. Each arm now follows its hand for as long as that hand is out.
  - **Anatomy:** shoulders below the skull, collarbones from the neck, the spine running up through the ribcage, hands resting just below the shoulders.
  - **Details:** thumbs turned inward; the nose cavity apex up.
- **Layers.** Giants are drawn in two layers: body, skull and resting hands behind the fighters, striking hands in front of them. Gashadokuro's spine no longer covers player 1.
- **Names.** Giants' names and notices are no longer clipped to their body width ("Gashadok").
- **Skirts** are built each frame around the legs, so the trailing leg is covered and no gap opens at the leading edge when crouching or jumping. The two-piece skirt is gone.

## 15.3

- **Gashadokuro in cut paper:**
  - ribcage, spine and collarbones looming behind the arena;
  - a skull with embered sockets that descends to bite, drops its jaw for the jaws, and glows when open;
  - arms reaching from its shoulders to hands that wait raised, slam down, lie open, or break to stumps;
  - pictures for the grabbing and clapping hands (the arms reach for them) and the falling bones.
- **One clap, high.** The low clap is gone. The high clap runs from just above any crouch to well over a jump, 118 to 400 units up, so it catches anyone standing and passes over anyone crouching.
- **Crouch height cap.** No fighter crouches taller than 115 units. Kawatarō, the shortest standing (128), was shorter than Shuten-dōji crouching (130), so no clap could have done both. The cap lowers only Shuten-dōji's crouch (130 to 115) and Benkei's (about 125 to 115), a small advantage to both.
- **Ushi-oni** has eight legs; with its front and back pairs broken it walks on the middle four.
- **Tests:** the clap against every fighter standing and crouching; the new pieces have pictures.

## 15.2

- **Ushi-oni in cut paper,** the first giant drawn:
  - a plated carapace with a spined ridge;
  - six jointed spider legs, near and far;
  - an ox head with horns and glowing eyes;
  - a walking scuttle, and its own motion for each attack (Leg Stab, Stomp, Charge, Poison Breath, Buck);
  - stumps for broken legs, a glowing head when exposed;
  - the poison cloud has a picture;
  - telegraphs show as outlines over the art.
- **Ushi-oni's back** reaches only 50 units up, not 170. Standing blows from his back pass over him; strike from his head, or crouched on his back. O-Yuki's icicle is now seen falling before it strikes him.
- **Skirts move:**
  - the upper piece follows the thighs (the forward one most);
  - the lower piece bends at its knee with the shins;
  - cloth that would reach below the floor rests on it.

  Crouching no longer pushes skirts through the floor, and a jumping knee stays covered.
- **Rokurokubi's head** flies on a circle from her own neck: up, over, and down onto the opponent at mid-height, about 380 ahead. The neck follows it with no kink.
- **Kojirō** is in side view.
- **Tools:** `tests/giants.gd` renders a giant through its attacks.

## 15.1

- **Walking without moonwalking.**
  - The old walk bent each knee while that leg was planted, and its sine-wave sweep could not match the body's speed. The new stride plants each foot: it sweeps back at exactly the body's speed (the thigh at the arcsine of the foot's offset over the leg), the other leg swings forward knee-high, and the hips dip to keep the planted foot on the ground.
  - Measured: planted feet slide about 0.1 px a frame against the body's 4, forward and back.
- **Arms:**
  - in profile, every character rests with the near arm low and the far arm high, and none rests behind;
  - wings are rooted at the shoulder blades and smaller;
  - the solver writes each answer in the turn nearest the arm's previous angle, so moves take the short way round.
- **Oni's drink:** passes through his guard between hip and mouth both ways, and lifts with the elbow forward.
- **Skirts** (Seimei, O-Yuki, Rokurokubi): wider; they cover the legs but not the feet, in two pieces jointed at the knee for kneeling.
- **Kojirō** is in chūdan-no-kamae: hands before the navel, the point at the throat.
- **Fox Step** reaches about a body length (160 px to the opponent's near edge). Within it she steps behind the opponent, however wide; beyond it she covers that distance and lands before them.
- **O-Yuki's icicle** forms no further than two body lengths (300 px) away.
- **Jorōgumo** keeps the shuffle in profile, with crouch and jump poses for spider legs.
- **Rokurokubi's long neck** grows from her own neck and curves along her head's path.
- **Strike effects** (the drum's shockwave, frost) show whether or not they connect.
- **Tests:** ranges, side-view guards, skirt coverage, the drink's path, planted feet.

## 15

- **Rig:**
  - **Joints.** Elbows and knees are limited, and the solver takes the bend the joint allows; this fixes elbows bending backward everywhere. Key poses can route a hand through a point, so the oni's drink arcs out in front.
  - **Two-handed grips.** The second hand slides along a long grip, the one flexible joint, and a key pose can release it.
  - **Hands and weapons.** Poses can place a hand by reaching and point a weapon at an absolute angle. Hanging parts stay upright.
  - **Walking.** A real stride in profile after the first steps; the diagonal view keeps its shuffle.
  - **Light attacks** use the free hand.
  - **Swings** may wound with only part of a weapon.
- **Pictures for pieces and effects:** shuriken, paper birds, water jet and wave, icicle, web and strand, lantern, fire, Rokurokubi's own head and skin-coloured neck, frost breath, belly drum shockwave.
- **Kojirō:**
  - diagonal, both hands on the grip, in the tail guard; traced swings for a quick stab, a rising and falling heavy, a Swallow Cut down and back up, and the Drying Pole lunge;
  - the lunge carries him about 50 px forward with the trailing hand letting go, tip only;
  - his light now reaches 203 (about 100 before), and the Swallow Cut 205.
- **Tomoe:** diagonal, the naginata in both hands in front of her.
- **Hanzō:** a forward-grip short blade.
- **En no Gyōja:** the staff planted in his trailing hand, the lead hand in a mudra.
- **Seimei:** robes to the ankles, a shorter cap, both arms visible and lower; paper birds flung underhand.
- **Tamamo-no-Mae:** three tails, fox ears, kitsune markings, reddish hair, a dagger.
- **Sōjōbō:** smaller, lower wings; his rear arm visible.
- **Kawatarō** is in profile. He leans in to spit his **water jet** from his head: it drives down at 30° and runs on along the ground as a low wave, and the wave counts as the same projectile.
- **O-Yuki:** a kimono wide at the hem, wider behind and short of her feet; her rear arm visible. Her **icicle** falls from above the opponent wherever they are, and on a giant.
- **Jorōgumo** is in profile: a kimono to the knee, spider legs below with a leg branching before and behind each, and two trailing low behind.
- **Rokurokubi:** the same hem as O-Yuki; a lantern hanging from a stick, thrown underhand.
- **Danzaburō** is in profile: round ears, straw hat pushed back, a leaf on his forehead during Leaf Disguise, both hands drumming his belly.
- **The oni's drink** passes out in front of him on the way up and down.
- **Tools:** `tests/scenes.gd` renders chosen moves mid-flight.

## 14.1

- **The oni:**
  - he rests with the kanabō diagonally on his trailing shoulder, arm bent in toward his torso;
  - the heavy raises the club in front of him to overhead and down, with no windmilling at the shoulder, and its start-up drops from 20 frames to 15;
  - the quake heaves the same way;
  - to drink, his lead hand reaches down to the gourd at his hip, lifts it to his mouth, and puts it back.
- **Rig:**
  - appendages (tails, wings, spider legs, shell) are drawn behind everything in every view;
  - props appear or hide within a window of a move, and hiding a part hides what's attached;
  - each rig names the arm that strikes;
  - unanimated attacks show that arm reaching toward the hitbox.
- **Basic rigs for all fourteen other fighters,** from a template and short descriptions, with resting guards from the art direction:
  - Kojirō in the tail guard; Tomoe's naginata low and forward; Benkei's polearm shouldered; Hanzō's reverse grip;
  - En no Gyōja's planted staff; Okuni's fan and talisman; Seimei's raised talisman and tall cap;
  - Tamamo-no-Mae's nine tails; Sōjōbō's wings, nose and feather fan; Kawatarō's sumo stance and shell;
  - O-Yuki's floor-length kimono; the Jorōgumo's yellow-banded spider legs; Rokurokubi's neck and lantern; Danzaburō's belly, hat, tail and flask.

  Their weapons are drawn only, so hitboxes are unchanged.
- **Tests and tools:** every fighter's rig joins up, with appendages behind and hitboxes untouched; props and Rokurokubi's head show and hide on cue; `tests/gallery.gd` renders everyone.

## 14

- **A shared humanoid rig** replaces the one-off puppets.
  - **Skeleton.** One skeleton with fixed bone lengths, whose limbs are named by role (lead and trail).
  - **Views.** Side, front and diagonal views each decide attachment, near and far, shape variants, shading and layer order. Parts are declared by kind (body, head, leg, clothing, arm segment, hand, weapon, decoration), and their order is computed rather than numbered. In the diagonal (aspective) view the lead side is far, which is why its leg sits behind.
  - **Shading.** Only depth darkens a part.
  - **No exceptions to layer order.** A weapon behind the torso stays behind it.
- **Reaching.** Two-bone inverse kinematics reaches a hand to named points, never stretching; the oni's drink now uses it.
- **Musashi** is ported to side view, lead side near. **Shuten-dōji** is ported to the diagonal view: both arms are drawn over his torso from its edges, his dragged club passes in front of his near trailing leg, and his far lead leg is shaded. This fixes the trailing arm that grew from his back, and the legs whose depth contradicted the arms.
- **Gameplay unchanged:** every traced move measures exactly as in 13.3.
- **Tests:** layer order and shading per view, attachment at the torso's edges, reaching a named point.
- **Next,** after review: two-handed weapons (the second hand solved onto the grip and free to slide along a long one, the only flexible joint), and moving between views within a move.

## 13.3

- **Principle corrected.** Poses must be anatomically plausible, and among plausible poses we choose the clearest and most striking, ignoring handedness. 13.2 had the oni holding his club in one hand while it rested on the other shoulder, and drinking from a gourd at one hip with the opposite hand.
- **Shuten-dōji:**
  - a boxing stance, chest toward us;
  - his free lead fist up and forward, which jabs;
  - the kanabō dragged low behind in his rear hand;
  - the gourd just inside his front hip, taken up by the lead hand to drink.

  The heavy hauls the club over from behind, with its start-up lengthened to 20 frames to match. The sweep and rising swing come out of the drag. The throw is one-handed.
- **Effects land with the blow.** The quake took effect while the club was still overhead; its slam now meets the ground on its first active frame. Both finishers likewise.
- **Engine and tests:**
  - a roster entry can set a fighter's own frame data for shared moves;
  - a new check requires every animated move with its own boxes to reach its impact pose as its active frames begin, and hold it through them.

## 13.2

- **Clarity over correctness.** Both puppets stand side-on like boxers, with weapons and props on the visible side.
- **Musashi:**
  - wakizashi in the near hand, levelled at the opponent; katana high in jōdan in the far hand;
  - his light thrust now visibly reaches farthest (136);
  - Two Heavens is a double thrust, wakizashi high and katana low;
  - scabbards, hakama pleats, a sleeve crest and a headband.
- **Shuten-dōji:**
  - kanabō carried on the shoulder, drawn behind his head;
  - free fist up in guard, its jab now the frontmost blow;
  - gourd always visible at the near hip, held to his mouth when drinking;
  - arm rings, beads, claws, the pelt's tail, a knotted sash.
- **Art direction:** guards for the whole roster (kenjutsu, HEMA, sumo, theatre); Kojirō in waki-gamae, the tail guard.
- **Engine and tools:** puppet parts can be hidden during moves; `tests/measure.gd` measures traced moves.

## 13.1

- **Weapons decide hits.** For puppet fighters, each move is a swing of key poses over its frame data. Its hitboxes are traced from the posed weapons on every active frame, and the puppet is drawn from the same poses.
- **Distance.** Weapons have damage zones: tip strongest, the hand end weakest.
- **Musashi:** wakizashi lights, katana heavies in a vertical arc, Two Heavens high with the wakizashi and low with the katana, a level answering cut, a grab-and-toss throw.
- **Shuten-dōji:** a backfist light, a true overhead kanabō swing, a club slam for the quake, a sake gourd, a lift-and-slam throw.
- **Faces** change visibly: the mask tilts up for teru, and down into shadow for kumoru.
- **Look:** thinner paper edges; sepia washi on warm paper for the menus, grey in fights.
- **Engine:** strikes carry a damage scale from the zone that landed; weapon geometry and swings live in the puppet data.
- **The computer** judges a move's reach only from boxes at a standing body's height. A traced swing passes through boxes overhead, and counting them had made Musashi's computer use his anti-air as a long poke; he won 0% of tournament bouts before this fix.
- **Swing fixes found by measurement:**
  - the crouching sweeps pointed into the floor;
  - both standing heavies never reached a crouching opponent;
  - Shuten-dōji's kanabō, at two-thirds of his height, reached 250 px; it is now about half his height and swung with a bent elbow, reaching about 200.
- **Tests:** the computer-against-computer check counts hits as they land (health resets between rounds).

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
