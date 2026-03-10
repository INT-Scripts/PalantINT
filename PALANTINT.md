# Direction Artistique (DA) - PalantINT

## 🔮 Le Manifeste : L'Anti-Générique & L'Esthétique de l'Ombre

PalantINT n'est pas un simple annuaire. C'est un outil de visualisation de données de campus. L'esthétique s'éloigne radicalement des interfaces génériques (dégradés violets sur fond blanc, Arial omniprésent). Nous adoptons un parti pris : un **Glassmorphism Sombre, Brutaliste et Luxueux** (Dark Luxury).

L'interface doit être élégante, lisible et performante, rappelant un outil professionnel haut de gamme.

---

## 🖤 Palette & Thématique : Profondeur Abyssale et Accents Tranchants

Nous construisons l'UI sur une échelle de Zinc (`zinc-950` quasi-noir) avec des accents saturés.

- **Le Vide (Fondation) :** `bg-zinc-950`. L'espace négatif est utilisé pour la clarté.
- **La Vitre (Glassmorphism) :** Les conteneurs utilisent des surfaces de verre fumé (`bg-zinc-900/40 backdrop-blur-xl border border-zinc-800/60`).
- **Arêtes Tranchantes (Brutalisme) :** AUCUN arrondi. Toutes les bordures doivent être strictement carrées (`rounded-none`). L'arrondi est banni pour renforcer l'aspect outil technique.
- **Lumière Atmosphérique :** Grain texturisé et orbes lumineuses discrètes sous le verre.

### 🩸 Accords de Couleurs
- **Étudiants :** Teintes bleues et violettes.
- **Campus / Logement :** Ambre / Orange.
- **Clubs & Organisations :** Émeraude / Vert.

---

## 🔤 Typographie & Langage : Clarté et Professionnalisme

- **Titres (Display) :** Brutaliste, étendue (Extended) ou géométrique.
- **Corps de texte (Body) :** Mono-espacée (Inter/Monospace) pour les données techniques.
- **Langage Naturel :** Utiliser des mots normaux et professionnels. Éviter le jargon technique dramatique (ex: "Déployer," "Séquence," "Extraction") et le *snake_case* dans l'interface utilisateur.
- **Universalité :** Cette règle de langage s'applique à **TOUTES** les interfaces, y compris les outils en ligne de commande (CLI) et les logs de synchronisation. Un outil haut de gamme parle un langage humain clair.

---

## 📐 Composantes Techniques

- **`<DataGrid />`** : Une grille de données haute densité, monospace, avec édition directe.
- **`<BuildingModel />`** : Un moteur WebGL (Three.js) rendu en fil de fer (wireframe) pour visualiser la structure physique des bâtiments.
- **`<InteractiveMap />`** : Plans SVG dynamiques avec manipulation directe du DOM pour une performance instantanée.
- **`<Schedule />`** : Un flux d'événements clair et chronologique.
- **Dégradés et Bruitages CSS :** Grain CSS en overlay pour une texture premium.
