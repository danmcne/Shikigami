# Changelog

Newest first. The README describes the current version only.

## 18.3

- **Hits are heard when they land, not when health falls.**
  - Fighters and giants now count the blows they receive and the blows they block, and the sound follows those counts. A blow on an invincible or armoured fighter is heard.
  - The silence in 18.1 was invincibility, not the sound: no health fell, so no hit played. 18.2's guess that the boom was too low for small speakers was wrong.
- **The 18.1 boom returns** for the heavy hit and the giant's hit; 18.2's mid-range crunch made them raspy.
- **A softer slam:** the giants' ground slam is a heavy thud with a soft rumble, without the crunching debris.
- **The giants' swing and thunder sounds stay,** so a miss is still heard.
- **Versus:** each fighter's shikigami are drawn at random each match from those it can bind, each with one of its specials at random. Before, it always got the first two in roster order with their first specials.
- **Tests:** blows that land are counted on the invincible, and blocked blows as blocked.

## 18.2

- **Giants are heard.**
  - **Why they weren't:** the boom for a giant's blow lay almost wholly below 150 Hz (1.5% of its energy above it), below what laptop speakers and most headphones reproduce. Impacts now have a body, a crunch and a rumble in the mid range: about 21% of the giant's hit lies above 150 Hz, and the fighters' heavy hit is filled out the same way.
  - **New sounds:** each giant attack plays a sound as it goes out, whether or not it lands. Swings, stabs, grabs, claps and bites rush like wind; slams, stomps and the Nue's dive and pounce strike the ground with a thud and scattering debris. Each lightning bolt strikes with a crack and a long roll of thunder.
- **Sounds are no longer dropped.**
  - There are now ten sound players.
  - The same sound asked for again within 70 ms is heard once, so a volley of bolts rolls one thunder.
  - When every player is busy, the one furthest through its sound gives way.

  Before, a volley of thunder filled all six players and any further sound, a hit included, was silently lost.
- **No stray hits between fights:** the health compared to detect hits resets when a new bout begins.
- **One-off sounds** are mixed into silence of their full length, so a long tail no longer wraps onto the start (the thunder had folded into 0.1 s).
- **Kawatarō's beak:** a larger upper triangle over a smaller, darker lower one, overlapping; the human mouth is gone.

## 18.1

- **The ensemble:** the music is rebuilt for four synthesized instruments in place of the koto.
  - **Shamisen:** a plucked string (Karplus–Strong) with a bright bachi attack and a buzz.
  - **Shakuhachi:** a breathy flute with vibrato that grows as a note is held.
  - **Taiko.**
  - **Kotsuzumi:** its "pon" rising in pitch.

  Each tune is a four-bar phrase played twice, the second time varied: the shamisen carries the phrase, the flute holds long notes over it, taiko marks the bars and kotsuzumi answers off the beat. Fight tune: 132 bpm; menu tune: 76 bpm, with more flute and space. Measured by energy, the fight tune is about 23% drums, 35% shamisen, 34% flute; nothing clips.
- **Tunes made in the background:** about a second each, on a worker thread at start-up; the music starts as soon as its tune is ready.
- **The round bell** rings as the "ROUND n" banner goes, on the first frame of fighting (frame 60), not as it appears. Banner and bell share one constant, `Bout.BANNER_FRAMES`.
- **Giants' blows** land with their own sound: a deep boom, a crack and a lingering rumble.

## 18

- **Sound and music,** all synthesized (`game/audio/sound.gd`):
  - **The bell:** a temple bell of inharmonic partials (about 1, 2.76, 5.4 and 8.9 times its fundamental) with a slow beat, rung as each round's fight begins.
  - **Effects:** a deeper gong at a knockout; hits as a thump and a crack, heavy at 60 damage or more; a wooden knock as a fighter starts to block; a tick on menu keys.
  - **Music:** two seamless looping tunes on D hirajōshi (D, E, F, A, B♭), koto-like plucks over taiko, 72 bpm for menus and 132 for fights. Each is scaled after mixing so it never clips.
  - **Controls:** F9 toggles sound and F10 music, both remembered.
  - **Cost:** the slowest sound to make (the fight tune) takes about 0.4 s, once, the first time it's needed.
  - **To listen:** `tests/export_sounds.gd` writes them all as WAV files.
- **Faces:** each fighter's face is its own (Musashi, the oni and Sōjōbō already were).
  - Humans:
    - Kojirō: a high ponytail.
    - Tomoe: a red headband.
    - Benkei: stubble and heavy brows.
    - Hanzō: a cloth mask.
    - En no Gyōja: a long white beard and heavy brows.
    - Okuni: white make-up, red lips, hair in a bun with a hairpin.
    - Seimei: a moustache.
  - Yokai:
    - Kawatarō: a beak.
    - O-Yuki: blue lips and hair falling across her face.
    - The Jorōgumo: a row of spider eyes and dark lips.
    - Rokurokubi: a white face and blackened teeth.
    - Danzaburō: a tanuki's dark eye patches.
- **Tests:** every sound is made, and both tunes loop.

## 17.5

- **Balance by Bayesian updating.**
  - **Method:**
    - `tests/pairs.gd` records every bout's winner;
    - `tests/bayes.py` gives each pairing a Beta posterior under a uniform prior, and calls it settled once one side is more than 90% likely the favourite;
    - each fighter's win rate is the mean of its posterior chances, with a 90% credible interval;
    - more bouts are spent only on open pairings;
    - after a change, only pairings involving the changed fighters are remeasured, while the rest keep their evidence (`tests/bouts_17_5.jsonl`).
  - **Changes, only to fighters whose intervals excluded 50%:**
    - the Jorōgumo's leg stabs reach as far as a spider's leg (110 standing, 105 crouching);
    - Seimei's birds strike for 62;
    - Kawatarō's water jet comes round every 85 frames, and his health is 720;
    - Benkei's Standing Death comes round every 6 seconds;
    - Kojirō keeps his quicker tempo at normal power.

    Typed lists can now be set in a fighter's own move data (they were silently refused).
  - **Standings** (664 bouts, posterior means with 90% intervals):

    | Fighter | Win rate |
    |---|---|
    | Benkei | 64 (57–72) |
    | Musashi | 64 (58–71) |
    | Kawatarō | 62 (55–69) |
    | Kojirō | 55 |
    | Tomoe | 54 |
    | Hanzō | 53 |
    | O-Yuki | 49 |
    | En no Gyōja | 48 |
    | the oni | 47 |
    | Tamamo-no-Mae | 47 |
    | Rokurokubi | 45 |
    | Okuni | 45 |
    | Danzaburō | 44 |
    | Sōjōbō | 43 |
    | Seimei | 42 |
    | the Jorōgumo | 40 (33–47) |

## 17.4

- **Every attack can land.** A new check gives every ordinary attack of every fighter, with bodies held apart by their push boxes, a chance to land on a normal, the widest and the smallest opponent. The oni's jab was the one that couldn't: level at his height, it passed over Kawatarō. It is now angled down; reach 118 (it was 136).
- **Comet tails restored:**
  - a blow's tail is drawn over the fighter (a fist's tail lay along the arm, hidden beneath it), a travelling body's behind;
  - a tail collects from six frames before contact, so it traces the whole drive;
  - a blow with no recorded leading point follows the hand its swing reaches with;
  - limb strikes follow the limb's end.
- **Balance:**
  - **Rush:** 45 damage. With the rising attack moved to the air, the rush had become the move every fighter leaned on.
  - **The Jorōgumo's web:** holds its victim for 40 frames, time for her kama to follow the pull.
  - **Toughness:** Danzaburō 1,050 health, Tamamo-no-Mae 800.
  - **Sōjōbō:** hits 10% harder.
- **Standings** (two bouts per pairing, margins about ±12; differences under about 15 points are within run-to-run noise):

  | Range | Fighters |
  |---|---|
  | 68–78% | Benkei 78; Musashi, Kojirō and Kawatarō 68 each |
  | 45–58% | Hanzō 58, En no Gyōja 53, Tomoe 52, the oni 50, O-Yuki 48, Rokurokubi 47, Danzaburō 47, Sōjōbō 45 |
  | Below 35% | Tamamo-no-Mae 35, Okuni 33, Seimei 25, the Jorōgumo 23 |
- **The giants** are left to playtesting: they need their own tactics, not the fighters' computer player.

## 17.3

- **Rebalancing** after weapon tracing, guided by tournaments (two bouts per pairing, Hard computer) and a new damage tool (`tests/damage.gd`). The tool credits each point of damage to the move that dealt it, and reports each fighter's move that is best against the most opponents.
- **System fixes that had decided fights:**
  - **Aiming:** blows now aim at heights in the world. Thrusts and the end of cuts no longer aim at the attacker's own shoulder, and hand-made ground boxes keep their world height while reaching farther for bigger fighters. Before, tall fighters' high blows passed over short ones.
  - **The rising attack's box** now starts from the feet. It used to rise over a short opponent's head: Musashi's rising connected 93 times in 124 against Tomoe but 42 in 95 against Kawatarō.
  - **The rising attack's role:** it is for the air. Against a grounded fighter it strikes for a third of its 60 damage; against the airborne and giants, in full. It starts in 4 frames and is invulnerable for 5.
  - **The rush** does 60 damage with 26 frames of recovery, so it can be punished when blocked.
  - **Typed lists** (spawn offsets and angles) are now filled correctly from move data. Seimei's pair of birds had silently flown as one.
- **The computer player:**
  - It keeps each fighter at its preferred distance: the weighted median of the fighter's damage rate across the distances its moves hit from, weighted toward each move's far reach. This runs from 20 (Tamamo-no-Mae) to 78 (Kojirō).
  - It remembers its last six moves and favours others, its anti-air and punish reflexes included.
  - Its punish chooses among every move fast enough to land, weighted by damage, instead of always the fastest.
  - Against giants: it seals a beaten giant at its core; it strikes up at a flying giant or jumps and throws at it from the air; it goes for the nearest strikeable part.
- **Fighters, each made more distinct:**
  - the oni: 1,550 health (his only change);
  - Benkei: Standing Death armour 40 frames, every 5 seconds;
  - Kawatarō: 760 health, size 0.86, a slower walk, a weaker water jet, a Charging Grab of 105;
  - Tamamo-no-Mae: 740 health, Bewitching Dust lasting 1 second;
  - Hanzō 800 and Danzaburō 950 health; Danzaburō's counter-slam 75;
  - O-Yuki: shorter slow from her breath, a rarer icicle;
  - Rokurokubi: a seeking, faster head (lands about 16 times in 39, against 3 in 33), striking for 100; 1,000 health;
  - Seimei: two birds climbing apart at 25° and 35°, 55 damage, every 48 frames;
  - Kojirō: hits 10% harder, faster tempo;
  - Sōjōbō: a gale of 40.
- **Standings** (two bouts per pairing, about ±11):

  | Range | Fighters |
  |---|---|
  | 70–78% | Musashi 78, Kawatarō 78, Benkei 70 |
  | 50–67% | Hanzō 67, Kojirō 62, Tomoe 53, En no Gyōja 53, O-Yuki 53 |
  | 35–47% | Rokurokubi 47, Okuni 45, the oni 43, Seimei 38, Tamamo-no-Mae 35 |
  | Below 35% | Sōjōbō 33, Danzaburō 25, the Jorōgumo 18 |

  These were measured before the rising attack became an air move and before the computer's giant play, which also changes its move choices, so the next run may differ.
- **Against the giants** (`tests/giant_eval.gd`; the computer at Hard, giants at Normal, three fights each):
  - **The Nue:** beaten by most fighters (Benkei and Tamamo-no-Mae never won).
  - **Ushi-oni:** beaten by no one, though the oni takes 55% of his health and most fighters 20–38%.
  - **Gashadokuro:** no one takes more than 6%. That reflects the computer player, which can't yet fight him (his parts are open only briefly), not the fighters.
- **Tests:** computed distances (Kojirō farther than Tamamo-no-Mae); Seimei's birds at 25° and 35°.

## 17.2

- **Blows are struck by what's held** (step 3 begun):
  - every held weapon has a striking segment with damage zones, and every blow struck with one is traced from it;
  - kicks, free-hand jabs and body blows keep their boxes, as do moves that send something out or take hold.
- **Reach after tracing** (standing light / heavy):

  | Fighter | Light / heavy |
  |---|---|
  | Musashi | 141 / 174 |
  | Kojirō | 203 / 188 |
  | Tomoe | 168 / 205 |
  | Benkei | 112 / 274 |
  | Hanzō | 102 / 106 |
  | En no Gyōja | 163 / 203 |
  | Okuni | 133 / 129 |
  | Seimei | 85 / 88 |
  | the oni | 136 / 169 |
  | Tamamo-no-Mae | 97 / 97 |
  | Sōjōbō | 155 / 172 |
  | Kawatarō | 72 / 92 |
  | O-Yuki | 96 / 91 |
  | the Jorōgumo | 90 / 117 |
  | Rokurokubi | 90 / 111 |
  | Danzaburō | 101 / 103 |

  **Rebalancing is next.** The extremes are Benkei's heavy (274) and the short crouching moves of Tamamo-no-Mae (36), O-Yuki and Seimei.
- **Motion trails:** a fading streak behind each blow's leading point in the colourway's red or blue; travelling moves trail the whole body.
- **Naginata Wheel:** the butt of the haft driven back at whoever is behind, then the blade thrust forward; traced, so it strikes behind first and in front after.
- **Crouching attacks end crouching** instead of standing for a frame.
- **Hanzō** kicks when crouching and in the air (his rising cut stays the kama's).
- **Frost Breath and Bewitching Dust are unblockable** (no guard stops a breath or a powder), and short: the breath reaches 105, the dust carries about 150.
- **Pictures:** Bewitching Dust (drifting fox-fire motes); the gale (streaming, curling wind).
- **The staff's ring** is a ring, open in the middle.
- **Tests:** traced moves strike only with what the rig holds; the wheel strikes behind and in front.

## 17.1

- **Flashing fixed:**
  - **The cause:** a crouching fighter's guard was solved with the body already lowered, so on a crouching move's first frame the arms jumped (up to 170°).
  - **The fix:** guards are now always solved relative to the standing body, the elbow solver prefers the solution nearest the arm's present angle, and arms at nearly equal depth keep their resting order instead of flickering.
  - **Measured:** single-frame jumps over 90° fell from 37 to 12, none of them in crouching moves. The rest come from very short start-ups and the second hand on fast polearm swings.
- **Counter stances** answer from their first frame, and their windows are 10 frames longer (Void Stance 34, Kawarimi 30, Leaf Disguise 40).
- **Seimei's seal** wards off blows as well as projectiles: a strike that meets it stops there.
- **Pictures:**
  - the talisman in flight, a paper strip with a red border and black strokes;
  - Okuni's Warding Seal, a talisman on the ground in a glowing ring;
  - Seimei's Five-Element Seal, a pane of light with the five-pointed star and hanging talismans;
  - held talismans marked to match.
- **Weapons and stances:**
  - Musashi's katana extends straight from his near forearm;
  - the kama is held with its haft up and a little forward, its blade forward and a little down and hooking down (an aim names where a blade across its haft points);
  - En no Gyōja's staff is held ringed end forward at face height;
  - Okuni's light and heavy are both the fan (a quick jab, a great swing), her trailing hand throwing talismans.
- **Crouching heavies differ by weapon:** two-handed weapons thrust low, swords and shouldered weapons sweep, the unarmed kick.
- **Tests:** the seal wards off blows; counters are ready from the start.

## 17

- **The verb library** (step 2): every fighter's attacks generated from verbs and holds under shared light/heavy conventions; signature moves keep their own swings. Traced arcs cut through their active frames; untraced moves hold contact through them.
- **Musashi** rebuilt to the convention, his moves from the verbs, each traced from its blade:
  - the wakizashi in his far hand, raised (light);
  - the katana in his near hand, held low (heavy);
  - Two Heavens staggered: wakizashi high, then katana low.

  Reach: light 141, heavy 174, Two Heavens 138.
- **Weapons and stances:**
  - Hanzō: kama in his near hand for both blade attacks, shuriken in his far hand;
  - Sōjōbō: in the boxer's stance, feather fan in his lead hand, a straight double-edged sword in his trailing hand;
  - Tamamo-no-Mae: claws on both hands;
  - O-Yuki: claws of ice;
  - the Jorōgumo: a kama in her near hand, a spider-leg stab for her light;
  - En no Gyōja: his staff as a polearm in both hands;
  - Kojirō: seigan, the grip held out before him, the point raised.
- **Gameplay:**
  - **Bewitching Dust** replaces Nine Tails: fox-fire powder whose victim swings at phantoms for 1½ seconds (their own blows and throws find nothing; they can still move, guard and send things out).
  - **Charging Grab** replaces Kawatarō's Sumo Grab: a short run into a grab.
  - **Leaf Disguise's statue slam** lunges, so its answer reaches the attacker.
- **Counters checked:** Void Stance (110) and Kawarimi (80) answer and wound at 80 and 140 apart; the statue slam missed at 140 before this fix.
- **Tests:** Bewitching Dust, the Charging Grab, every fighter's ordinary attacks animated.

## 16

- **The turning upper body,** step 1 of the general animation system.
  - The rig gains a turn joint (yaw) for the upper body. The shoulders lie on a circle about the spine, so turning moves them forward and back and nearer and farther. Arms layer and shade by depth, behind the torso when turned clearly away, otherwise over it, farther first. The torso's cut follows the turn.
  - Side, diagonal and front views become resting turns: 0° (or 180°), about 120°, and 90°. They reproduce every fighter's shoulders exactly, and all traced reach measures as before.
- **Demonstrations:**
  - Kawatarō's light is a profile jab with his far arm, turning to −60° to bring that shoulder forward;
  - Tamamo-no-Mae's heavy is a boxer's cross with her free trailing hand, turning from 120° through profile to 225°.

  Both animate over their existing hitboxes; tracing for everyone is step 3.
- **Tests:** resting turns keep the shoulders; turning gains reach; arms layer by the turn.

## 15.6

- **Rokurokubi:** no separate neck; her head sits on her shoulders. When it flies, it leaves from where it sits, and the long neck grows from that same point and follows the head's path, with no kink.
- **Nue:** a thick, furry neck joins the front of its body to its head and follows the head when it moves.
- **Tests:** the flying head leaves from its seat on her body.

## 15.5

- **Nue in cut paper,** the last giant drawn:
  - a tanuki's round, shaggy body on a billowing, crackling thundercloud;
  - a red monkey face in a pale ruff;
  - four striped tiger legs with claws, near and far;
  - a snake for a tail.
- **Nue's motion:**
  - legs tuck in flight, and it bobs;
  - grounded, it walks;
  - each attack has its own motion (lightning, dive, tail strike, thrash, claw, tail lash, pounce);
  - lightning bolts have a jagged picture.
- **Nue's back** reaches only 50 units up, as Ushi-oni's does: standing blows from there pass over it; strike it crouched.

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
