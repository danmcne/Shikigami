# Art and audio direction (first thoughts)

Nothing here is built yet. The aim is a style that is unmistakably Japanese, consistent across 16 fighters, 3 giants and 3 stages, and cheap enough for a small team to finish.

## The proposal: a paper theatre

**Characters are paper-cut puppets with theatre faces; the world is ink and ukiyo-e colour.** Each tradition you named contributes something that also solves a production problem:

- **Kiri-e (cut paper) and bunraku puppets** suggest characters built from a dozen flat, cut-out parts (head, torso, upper and lower arms and legs, weapon, sleeves) that rotate at joints. That is cut-out animation. One set of parts per fighter gives every pose: no frame-by-frame drawing, and animation becomes key poses on a skeleton, which suits frame data. Godot's Skeleton2D and Polygon2D do this natively.
- **Noh masks and kabuki kumadori** give faces that never animate. A mask or painted face is fixed by tradition, so no facial animation is needed anywhere, and each face carries identity at a glance:
  - hannya and oni masks for the yokai;
  - kumadori for the warriors;
  - ko-omote for Okuni.
- **Ukiyo-e** gives flat colour areas with a strong outline, a limited palette per character, and the backgrounds' composition: bands of flat colour, framing branches, distant mountains. Hiroshige for places, Kuniyoshi for warriors and monsters.
- **Sumi-e (ink wash)** is for the giants and for effects. Gashadokuro as a looming ink silhouette, Nue in a smear of thundercloud, ink splashes for hits, and dry-brush streaks for motion. Ink suits enormous things: it suggests rather than details them.
- **One finishing touch over everything:** a washi paper texture and a slight ink outline. Placeholder art and final art then look like one world.

What this avoids: hand-drawn frame animation for 16 fighters (by far the biggest cost in 2D fighting games), and facial animation altogether.

## Player 1 and player 2: tori and uke

Each fighter gets two colourways from the same parts, by palette swap: one shader maps a few colour slots per part.

| | Player 1 (tori) | Player 2 (uke) |
|---|---|---|
| Colours | vermilion, ivory and gold | indigo, ash and silver |
| Kumadori meaning | red: courage, the hero | blue: the dark side, the supernatural |

Mirror matches therefore read instantly, and spirits keep their owner's colourway, washed out and translucent.

## Giants

Each giant is a set of large ink-and-paper parts matching its gameplay parts: shell, legs and head; hands and skull; body, face, tail and thundercloud.

- **Breaking.** A broken part tears, with a paper edge, and greys.
- **Weak points.** These are the one place a giant gets bright colour. They are gold when open, which matches what the prototype already shows.

## Three backgrounds to start

Giant arenas wrap round, so their backgrounds must be seamless panoramas: three parallax layers, each repeating at the arena's length.

1. **Shore at dusk** (Ushi-oni's home; also a standard stage). A Hokusai sea with rocks, and a red torii standing in the water.
2. **Ruined hall at night** (Gashadokuro's enclosure). Broken shoji and pillars. The skeleton fills the sky beyond the roofless beams, and moonlight falls through the paper walls.
3. **Palace roofs under storm** (Nue, after Yorimasa's legend). Tiled roofs and the emperor's palace, a black sky and lightning.

## Interface

- **Lettering:** names in brush calligraphy.
- **Health:** each bar a single brush stroke that dries and cracks as health falls.
- **Recharges:** filling ink circles (ensō).
- **Seals:** sealing stamps a red hanko seal across the screen.
- **Round calls:** hyōshigi clappers, as in kabuki.

## Sound effects

- **Strikes:** wooden clacks (hyōshigi) for guarded hits; drum hits for heavy blows, from ōtsuzumi or taiko, with pitch by weight.
- **Spirits:** a paper rustle and a small bell (suzu) when a spirit is summoned. Summon and seal share a temple bowl (rin), whose ring is the sound of binding.
- **Specials:** kakegoe, the drummers' shouts of noh and kabuki ("yo-o!", "ha!"), on special moves.
- **Giants:** the giants' telegraphs each have a distinct cue, so attacks can be heard coming:
  - Ushi-oni: low, wet groans;
  - Gashadokuro: bone rattles (bin-sasara);
  - Nue: thunder, and a strange bird-like cry (legend says it called like a thrush).

## Music

The instruments you named are koto, shamisen, shakuhachi and taiko. To them I'd add the noh flute (nōkan) for tension, and the biwa for story scenes.

- **Stages.** Short loops built in layers: a taiko ostinato, shamisen riffs, and koto colour. The music adds layers as rounds go on, and when either fighter is low on health (Godot 4.3's interactive music streams do this).
- **Giants.** Slower and heavier: ōdaiko and drones, shakuhachi, sparse nōkan cries. A giant's music drops to near silence during its sealing window, then strikes a final drum.
- **Menus.** Solo koto or biwa.
- **Sources.** Sample libraries of these instruments exist; live recordings of a few performers would give the most character for the least material.

## Ease and order

1. A style test of two fighters (Musashi, and Shuten-dōji as the contrasting yokai): parts, both colourways, idle, walk and one attack, against one background layer.
2. Rig and animate the shared kit's poses once, then reuse the timings across fighters with similar builds.
3. Giants last; they need few poses but large parts.

Throughout, the prototype's boxes stay the source of truth, with the art drawn to fit them.

## Names to consider for the yokai

The three named humans were added in version 12. Legends also offer names for some yokai, should we want named individuals rather than kinds:

- **Tamamo-no-Mae,** the nine-tailed fox (fits Nine Tails);
- **Sōjōbō,** king of the tengu, who taught Yoshitsune;
- **Danzaburō-danuki,** the tanuki of Sado;
- **O-Yuki,** the snow woman of Lafcadio Hearn's tale;
- **Kawatarō,** a common name for the kappa.

Shuten-dōji is already a named individual.
