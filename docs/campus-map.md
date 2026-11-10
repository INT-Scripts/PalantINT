# Carte du campus : sources et pipeline

`/palantint/campus` affiche une seule carte MapLibre. Le plan et la vue 3D en sont deux modes de rendu (caméra à plat ou inclinée) ; la sélection, le bâtiment, l’étage et l’URL sont partagés.

## Sources

| Couche | Origine | Archive brute (`SCRAPS_AUTO_DIR`) | Produit publié | Route privée `/api/private/maps/indoor/…` |
| --- | --- | --- | --- | --- |
| Lieux, bâtiments, salles | Wemap | `wemap/` | `GEO_PLANS_DIR/campus.geojson` + table `Location` | `geojson`, `manifest`, `lookup` |
| Plans historiques placés | SVG → GeoJSON + Wemap | `plans/plan-registration.json` | `Location.attributes.plan_georeference` des étages | `plans` |
| Fond de carte | OpenStreetMap (ODbL) | `basemap/overpass.json` | `GEO_PLANS_DIR/basemap.geojson` | `basemap` |
| Photographie aérienne 20 cm | IGN `HR.ORTHOIMAGERY.ORTHOPHOTOS` | `ign/aerial/{z}/{x}/{y}.jpg` | `GEO_PLANS_DIR/aerial/` (liens physiques) | `aerial`, `aerial/{z}/{x}/{y}.jpg` |
| Relief 3D des alentours | IGN LiDAR HD : MNT (terrain) + MNH (sursol), orthophoto | `ign/heights/{z}/{x}/{y}.npz` | `GEO_PLANS_DIR/relief/{z}/{x}/{y}.glb` | `relief`, `relief/{z}/{x}/{y}.glb` |
| Photogrammétrie du campus | Scan calibré (`input_gltf/`) | — | `ASSETS_DIR/3d` | `/maps/3d-tiles`, `registration` |

Toutes ces routes exigent une session. Les données sont conservées localement : la carte ne dépend d’aucun serveur de tuiles tiers. Les attributions (Wemap, © OpenStreetMap, © IGN) sont affichées sous la carte.

## Pipeline

Les domaines du pipeline (`uv run palantint sync`, depuis `scripts/`) suivent la règle Harvest → Ingest :

| Domaine | Collecte | Import |
| --- | --- | --- |
| `wemap` | extraction Wemap | lieux et géométries dans `Location` |
| `plan_georeference` | calcul du placement des plans (après `wemap`) | `Location.attributes.plan_georeference`, source `plan_georeference`, `IngestionRun` |
| `basemap` | Overpass archivé, GeoJSON publié | — (fichier servi) |
| `ign` | tuiles et grilles LiDAR manquantes archivées, puis orthophoto et relief publiés | — (fichiers servis) |

Commandes unitaires :

```sh
uv run palantint other georef                     # calcul du placement (import : sync, domaine plan_georeference)
uv run python -m palantint_scripts.loaders.plan_georeference
uv run palantint other basemap [--offline]        # OSM, 1,5 km autour du campus
uv run palantint other ign [--offline]            # orthophoto (z13–z19) et relief 3D
```

`--offline` reconstruit les produits publiés depuis les archives, sans téléchargement. Relancer `plan_georeference` après une nouvelle extraction Wemap ou une conversion des plans.

## Placement des plans historiques

`palantint_scripts.plan_registration` estime, plan par plan, une similitude (rotation, échelle, translation) du repère du dessin vers des mètres est/sud d’une origine fixe :

1. `room_labels` : numéros de salle communs au plan et à Wemap, ajustés par RANSAC (tolérance 2 m, RMS ≤ 1,5 m) ;
2. `room_shapes` : contours des salles comparés aux salles Wemap non numérotées du même bâtiment (recherche d’orientation et d’échelle, puis ICP). Refusé si l’écart moyen dépasse 0,6 m ou si une autre orientation convient presque aussi bien ;
3. `outline` : empreinte du plan comparée au contour nommé du bâtiment (Wemap, puis OSM), avec les mêmes garde-fous.

Les points de contrôle manuels (`plan-georeferencing.json`, voir `floor-plan-geojson.md`) restent prioritaires. Un plan ambigu reste non placé et Wemap est conservé ; la raison est enregistrée sur l’étage et renvoyée par `/plans` (`metadata.unplaced`). Le niveau Wemap de chaque plan vient des salles appariées, sinon du décalage d’étage commun aux autres plans du bâtiment.

Le loader enregistre chaque placement (ou la raison de son absence) sur l’étage concerné, sans toucher aux autres attributs. Le serveur (`services/plan_geography.py`) applique ces transformations aux fichiers publics des plans, relie les logements à leur `Location` et les salles du Foyer à leurs associations, et signale les lieux Wemap couverts (`metadata.superseded`) que la carte n’affiche plus. Les géométries WGS84 obtenues restent privées.

État au 2026-11-10 : 28 plans sur 37 placés (U1–U4 par numéros, RMS 0,2–1,3 m ; U7 et Foyer par formes). U5 (correspondance insuffisante) et U6 (absent de Wemap et d’OSM) restent sur Wemap.

## Logements et Foyer dans le panneau

La carte remplace les anciennes pages `/palantint/apartments` et `/palantint/foyer`.

- Logement : `/api/private/maps/indoor/locations/{id}` renvoie, pour un `Location` APARTMENT, un bloc `apartment` typé (type, surface, loyer, aides boursier/non boursier et loyers nets) lu dans ses attributs Maisel. Les données Maisel ne contiennent pas de critère PMR ; seule l’accessibilité Wemap (`wheelchair`) est affichée lorsqu’elle existe.
- Résidence : `/api/private/maps/indoor/housing` résume chaque résidence (logements, occupés, nombre et fourchette de loyers par type).
- Foyer : les salles dessinées du Foyer portent leurs associations (`clubs` : identifiant, nom, logo) depuis `build_foyer_index`.
- Anciens liens : le proxy Next redirige (307) les deux pages vers `/palantint/campus?building=…&level=…&feature=…`. `/api/private/maps/indoor/legacy` traduit `bldg`, `floor` (étage du plan historique) et `room` à partir des placements ingérés, sinon de Wemap, sinon du seul bâtiment. La carte utilise ce même service pour un paramètre `room` qu’elle ne trouve pas parmi les salles dessinées.

## Relief et photogrammétrie

Le relief IGN est découpé en cellules z18 (≈ 100 m) : maillage de 129×129 nœuds et texture 20 cm sur le campus, 65×65 et 256 px autour. La surface est le terrain (MNT) plus la hauteur de sursol (MNH) lissée par une médiane 3×3 sans couture entre tuiles, exprimée par rapport au sol du campus (`ground_reference_m` de l’index, MNT médian de la cellule centrale) : le campus repose sur la carte plane et les alentours conservent leur relief réel.

Le scan du campus est placé par la transformation inverse de `/maps/indoor/registration` (marqueurs de calibration de l’administration). Là où il existe, il fait référence : le relief est masqué sous son emprise (union des enveloppes convexes des tuiles, érodée de 10 m au bord extérieur seulement pour que le relief recouvre le bord irrégulier du scan). La plupart des tuiles du scan sont compressées en Draco ; le décodeur fourni avec three.js est servi localement depuis `frontend/public/draco/`. Les deux surfaces sont rendues par une couche personnalisée three.js dans le contexte WebGL de MapLibre (`reliefLayer.ts`).
