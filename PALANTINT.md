# Direction Artistique (DA) - PalantINT

## 🔮 Le Manifeste : L'Anti-Générique & L'Esthétique de l'Ombre

PalantINT n'est pas un annuaire. C'est une immersion. L'esthétique s'éloigne radicalement de la "soupe IA" (les sempiternels dégradés violets sur fond blanc, l'Arial ou l'Inter omniprésents). Nous adoptons un parti pris extrême : un **Glassmorphism Sombre, Brutaliste et Luxueux** (Dark Luxury & Intelligence Agency Vibe).

L'interface doit évoquer un outil gouvernemental classifié de l'an 2040, mais avec l'élégance d'une revue d'art digitale. 

---

## 🖤 Palette & Thématique : Profondeur Abyssale et Accents Tranchants

Fini les couleurs fades. Nous construisons l'UI sur une échelle de Zinc (`zinc-950` quasi-noir) et nous perçons l'obscurité avec des **accents tranchants et saturés**.

- **Le Vide (Fondation) :** `bg-zinc-950`. L'espace négatif doit être magistral or claustrophobique selon l'effet désiré. L'interface joue avec la densité.
- **La Vitre (Glassmorphism) :** Les conteneurs ne sont pas de simples blocs. Ce sont des surfaces de verre fumé (`bg-zinc-900/40 backdrop-blur-xl border border-zinc-800/60`).
- **Lumière Atmosphérique :** Emploi de générateurs de bruit (grain texturisé) et d'orbes bioluminescentes (Bleu Océan, Violet Électrique, Ambre, Émeraude) sous le verre.

### 🩸 Accords de Couleurs Asymétriques
- **Spy/Agents (Étudiants) :** Teintes néon bleues et violettes.
- **Infiltration (Campus) :** Orange thermique (Heatmap/Ambre).
- **Opérations (Clubs) :** Émeraude toxique et Vert fluor.

---

## 🔤 Typographie : Caractère et Radicalité

Interdiction d'utiliser Roboto, Arial, ou Inter. L'interface doit mélanger des polices inattendues pour créer une friction visuelle maîtrisée.

- **Titres (Display) :** Brutaliste, étendue (Extended) ou géométrique/Art Déco tranchante. Les titres peuvent percer la grille ou chevaucher des images de fond.
- **Corps de texte (Body) :** Mono-espacée (Monospace) ou Serif affûtée (Tech/Editorial) pour les données textuelles, rappelant l'interface terminal d'un hacker, mais hautement raffinée.

---

## 🪄 Mouvement et Micro-Chorégraphie

Rien n'apparaît de manière abrupte. Tout est orchestré.

- **Load Staggering :** Plutôt que de nombreuses micro-animations aléatoires, l'arrivée sur la page est un événement. Les données (Cartes Étudiants, Badges) s'affichent en cascade avec des délais (animation-delay).
- **Le Hover "Vivant" :** Interaction inattendue au survol. Ne pas se contenter de changer de couleur. Élévation dramatique, activation du "glow" autour des bordures, modification de l'échelle (`transform`), et distorsion subtile du blur arrière.
- **Scroll Triggers :** Apparitions spatiales asymétriques au fur et à mesure de l'exploration des données.

---

## 📐 Composition Spatiale : Briser la Grille

PalantINT refuse l'approche "Cookie-Cutter" en ligne/colonne académique.

- **Densité vs Espace Vierge :** Contraste absolu. Certaines zones croulent sous l'information analytique terminale (badges condensés textuellement), d'autres respirent royalement (un Avatar surdimensionné flottant en demi-teinte).
- **Asymétrie et Superposition :** Les cartes n'ont pas peur de déborder subtilement les unes sur les autres. Les badges de statut mordent sur les bordures du verre. 
- **Détails Éditoriaux :** Des curseurs personnalisés pour les cartes interactives, des lignes de repères (crosshairs) subtiles en SVG, ou des motifs géométriques technologiques (grilles radar) en transparence.

---

## 🧩 La Composante Technique de l'Élégance

L'esthétique de luxe exige une implémentation millimétrée (Precision Engineering) :

- **`<Avatar />`** : Immenses sur les pages détails, brisant la norme des petits cercles mornes. Bords nets avec un inner scale effect. Ring-glow massif.
- **`<Input />`** : Fusionnés avec le vide. Un trait lumineux qui n'apparaît pleinement que lors de la prise de focus, semblable à un sonar actif.
- **Dégradés et Bruitages CSS :** L'usage impétueux de `mix-blend-mode: screen`, opacités complexes et grain CSS en overlay pur au-dessus de chaque page. 

*Aucune génération de vue ne doit se ressembler banalement. Concevez chaque écran comme l'interface finale d'un thriller d'espionnage futuriste.*
