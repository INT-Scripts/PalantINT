# Plans historiques en GeoJSON

Les plans de logements et du Foyer utilisent le même fichier GeoJSON pour le rendu Canvas 2D, la reconstruction Three.js et la calibration administrative. Les sources SVG restent archivées dans `SCRAPS_MANUAL_DIR / "input_svgs"`. Aucun viewer de plan ne charge le SVG ou une prévisualisation PNG.

## Production et vérification

Depuis `scripts/` :

```sh
uv run palantint other map
```

La commande de conversion reste disponible dans `uv run palantint`. La vérification des plans contrôle maintenant les fichiers `.geojson`, leurs identifiants et leurs géométries. Le catalogue serveur `/api/maps/catalog` fournit leurs URL publiques `/api/assets/plans/{building}_{floor}.geojson`. Les plans Wemap restent servis exclusivement par les routes privées.

La conversion conserve les identifiants des textes, les murs, les courbes échantillonnées, les transformations et les trous des polygones. Les régions fermées sont extraites par composantes connexes à deux pixels par unité source ; `extraction_tolerance` indique la précision. Une zone ouverte ou partagée par plusieurs identifiants reste un point à vérifier, sans rectangle inventé.

L’état initial comprend **37 plans, 899 identifiants et 894 polygones de salles**, plus 238 espaces sans numéro détectés automatiquement. Cinq contours restent à corriger dans les sources : `2535`, `2534` (U2, étage 5), `5405`, `5404`, `5403` (U5, étage 4). Le manifeste liste ces identifiants par plan.

## Couloirs, escaliers et espaces sans numéro

Les SVG ne nomment que les chambres et salles numérotées. La conversion ajoute aussi :

- un `floor` par plan : la dalle de l’étage, union des zones fermées (murs compris), sans les zones marquées « vide » ;
- un espace (`space`) pour chaque zone fermée restante d’au moins 100 unités², identifiant `auto-<x>-<y>` (point intérieur), `extraction = "unlabelled_enclosure"` ;
- les espaces définis à la main : `corridor`, `stairs`, `elevator` ou `space`, avec `space_id`, un `name` facultatif et `extraction = "defined"`. Leur identifiant de feature est `plan:<bâtiment>:<étage>:space:<id>`, quel que soit leur type.

Les définitions sont dans `PLAN_SPACES_PATH` (`SCRAPS_MANUAL_DIR / "metadata" / "plan-spaces.json"`), source manuelle sauvegardée par le Vault (`map_references.json`, restaurée seulement si le fichier manque) :

```json
{
  "U7_2": {
    "partitions": [[[323.3, 298.6], [323.3, 351.0]]],
    "spaces": [
      {"id": "corridor-1", "kind": "corridor", "name": "Couloir", "point": [380, 320]},
      {"id": "void-1", "kind": "void", "point": [500, 600]}
    ]
  }
}
```

Chaque espace prend la zone fermée sous son `point`. Une `partition` est une cloison tracée seulement dans le raster d’extraction, pour séparer deux zones ou fermer une zone ouverte. Elle n’est jamais publiée comme mur et sert aussi aux contours de salles. `void` retire la zone du sol (patio, jardin, gaine). Un point sur une salle numérotée, hors du bâtiment ou dans une zone partagée reste un point listé dans `metadata.unresolved_spaces`.

Éditeur local, depuis `scripts/` :

```sh
uv run palantint other spaces   # http://127.0.0.1:8765/
```

Cliquer sur une zone grisée pour la qualifier (touches `1`–`5`), `C` pour tracer une cloison (aimantée aux murs, `Maj` pour enchaîner), `N` pour placer un espace à la main. L’aperçu se recalcule à chaque modification. `Ctrl+S` enregistre le fichier et régénère le GeoJSON du plan et le manifeste.

La carte du campus dessine ces espaces comme les circulations Wemap (2D et 3D) ; seules les salles numérotées restent sélectionnables. `plan_registration` n’utilise que les salles.

## Coordonnées et placement géographique

Chaque fichier est une FeatureCollection :

- `metadata.plan_coordinate_space = "local_plan"`, `view_box`, bâtiment, étage, compte de salles, source et empreinte SHA-256 ;
- `properties.plan_geometry` contient la géométrie locale d’origine ;
- `geometry` contient uniquement des coordonnées WGS84 validées, sinon `null` ;
- `properties.label_coordinates` conserve le point d’étiquette local.

Il ne suffit donc pas de passer les fichiers non placés directement à MapLibre : il faut leurs points de contrôle. Wemap ne couvre pas toutes les chambres U5–U7. Aucune position géographique n’a été inventée ou copiée depuis les données privées vers ces fichiers publics.

Le fichier facultatif `SCRAPS_MANUAL_DIR / "metadata" / "plan-georeferencing.json"` associe chaque nom de plan à au moins trois points non alignés :

```json
{
  "U7_1": [
    {"plan": [0, 0], "geographic": [2.44, 48.62]},
    {"plan": [100, 0], "geographic": [2.441, 48.62]},
    {"plan": [0, 100], "geographic": [2.44, 48.619]}
  ]
}
```

Ces valeurs illustrent le format, pas une calibration du campus. Le calcul de placement (`plan_registration`, domaine `plan_georeference`) ajuste une similitude en mètres, refuse une erreur RMS supérieure à 3 m et enregistre le placement (méthode `control_points`) avec les autres, en privé : `map_gen` n’écrit jamais ces coordonnées dans les fichiers publics. Sans niveau Wemap, un étage placé manuellement prend la valeur de son étage de plan. Le Vault sauvegarde ces points et restaure le fichier seulement s’il manque, sans écraser une version locale plus récente.

Les deux piliers de calibration 3D existants restent en pourcentages de plan et conservent leur rôle. Ils ne remplacent pas trois points géographiques mesurés. Un fond de carte géographique pourra être ajouté sous les plans placés, avec une source de tuiles et son attribution adaptées.

## Placement sur la carte du campus

Sans points de contrôle manuels, `uv run palantint other georef` estime le placement de chaque plan à partir de Wemap (numéros de salle communs, sinon formes des salles) et l’écrit dans un fichier privé. La carte `/palantint/campus` dessine alors ces plans à la place des salles Wemap qu’ils couvrent, en 2D comme en 3D. Méthodes, seuils et état : `campus-map.md`.

Les alignements 3D ci-dessous (marqueurs et piliers) restent utilisés par l’administration et pour placer le scan photogrammétrique du campus.

### Récupérer les alignements déployés

Se connecter sur le portail déployé puis coller le contenu de `scripts/tools/export-3d-alignments.js` dans la console du navigateur. La commande lit la configuration 3D et les seules calibrations d’étages, puis télécharge `palantint-3d-alignments.json`. Aucun jeton, occupant ou dossier personnel n’est inclus. Les routes actuelles et historiques sont prises en charge. En cas de session expirée, se reconnecter puis relancer.

Placer le fichier dans `SCRAPS_MANUAL_DIR / "metadata" / "palantint-3d-alignments.json"`. Depuis `scripts/` :

```sh
uv run python -m palantint_scripts.alignment_transfer ../data/scraps/manual/metadata/palantint-3d-alignments.json
```

L’import valide le format, les valeurs et les étages connus avant de toucher aux données. Il archive les valeurs précédentes et la provenance dans `EXPORTS_DIR / alignments-before-<date>`, puis applique la mise à jour dans une transaction. Il conserve les marqueurs locaux absents de l’export. Le Vault standard sauvegarde ensuite l’état importé. Recharger la page 3D après l’import.
