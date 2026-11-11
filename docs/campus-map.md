# Carte du campus : sources et pipeline

`/palantint/campus` affiche une seule carte MapLibre. Le plan et la vue 3D en sont deux modes de rendu (caméra à plat ou inclinée) ; la sélection, le bâtiment, l’étage et l’URL sont partagés.

## Sources

| Couche | Origine | Archive brute (`SCRAPS_AUTO_DIR`) | Produit publié | Route privée `/api/private/maps/indoor/…` |
| --- | --- | --- | --- | --- |
| Lieux, bâtiments, salles | Wemap | `wemap/` | `GEO_PLANS_DIR/campus.geojson` + table `Location` | `geojson`, `manifest`, `lookup` |
| Plans historiques placés | SVG → GeoJSON + Wemap | `plans/plan-registration.json` | `Location.attributes.plan_georeference` des étages | `plans` |
| Fond de carte | OpenStreetMap (ODbL) | `basemap/overpass.json` | `GEO_PLANS_DIR/basemap.geojson` | `basemap` |
| Photographie aérienne 20 cm | IGN `HR.ORTHOIMAGERY.ORTHOPHOTOS` | `ign/aerial/{z}/{x}/{y}.jpg` | `GEO_PLANS_DIR/aerial/` (liens physiques) | `aerial`, `aerial/{z}/{x}/{y}.jpg` |
| Relief 3D des alentours | IGN LiDAR HD : MNT (terrain) + MNH (sursol), orthophoto | `ign/heights/{z}/{x}/{y}.npz` | `GEO_PLANS_DIR/relief/{z}/{x}/{y}.bin` | `relief`, `relief/{z}/{x}/{y}.bin` |
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

État au 2026-11-11 : 34 plans sur 37 placés (U1–U4 par numéros, RMS 0,2–1,3 m ; U7 et Foyer par formes ; U5, tous ses étages, par points de contrôle manuels validés sur l’orthophoto, dérivés de l’ajustement au contour OSM de U5 puis de l’alignement des étages entre eux ; le sous-sol, ajusté sur les salles de l’étage 2, reste incertain : environ 8° d’écart). U6 n’est pas sur le campus : d’après la carte Maisel, c’est une barre nord–sud à l’est de la cathédrale d’Évry, hors de l’emprise de la carte. Il n’est volontairement pas placé et s’affiche à part (voir ci-dessus).

## Logements et Foyer dans le panneau

La carte remplace les anciennes pages `/palantint/apartments` et `/palantint/foyer`.

- Logement : `/api/private/maps/indoor/locations/{id}` renvoie, pour un `Location` APARTMENT, un bloc `apartment` typé (type, surface, loyer, aides boursier/non boursier et loyers nets) lu dans ses attributs Maisel. Aucune source n’indique les logements adaptés PMR (personnes à mobilité réduite) : ni les fiches Maisel ni ses plans, ni `apartments.txt`/`apartments.csv`, ni les SVG (vérifié le 2026-11-11). Seule l’accessibilité Wemap (`wheelchair`) est affichée lorsqu’elle existe.
- Résidence : `/api/private/maps/indoor/housing` résume chaque résidence (logements, occupés, nombre et fourchette de loyers par type).
- Foyer : les salles dessinées du Foyer portent leurs associations (`clubs` : identifiant, nom, logo) depuis `build_foyer_index`.
- Résidence hors carte : `/api/private/maps/indoor/local-plans` sert les plans des résidences dont aucun étage n’est placé (U6), en coordonnées de plan, reliés à leurs logements comme `/plans`. La carte les dessine à part (canvas) avec le même panneau.
- Anciens liens : le proxy Next redirige (307) les deux pages vers `/palantint/campus?building=…&level=…&feature=…`. `/api/private/maps/indoor/legacy` traduit `bldg`, `floor` (étage du plan historique) et `room` à partir des placements ingérés, sinon de Wemap, sinon du seul bâtiment. La carte utilise ce même service pour un paramètre `room` qu’elle ne trouve pas parmi les salles dessinées.

## Relief et photogrammétrie

Le relief IGN est découpé en cellules z18 (≈ 100 m) : grille de 256×256 nœuds (≈ 40 cm, proche du LiDAR 50 cm ; 65 536 sommets, donc des indices 16 bits) et texture 20 cm sur le campus, 65×65 et 256 px autour. Il utilise les deux modèles LiDAR HD : le MNT (terrain) et le MNS (surface : toits, canopée), en grilles d’altitude `ELEVATIONGRIDCOVERAGE.LAMB93` (les couches `…SHADOW` du même nom ne sont que des estompages, sans altitudes). La surface est le terrain plus l’écart MNS − MNT lissé par une médiane 3×3 sans couture entre tuiles, exprimée par rapport au sol du campus (`ground_reference_m` de l’index, MNT médian de la cellule centrale) : le campus repose sur la carte plane et les alentours conservent leur relief réel.

Les marqueurs de production ont été importés le 2026-11-11 (`alignment_transfer`) : 4 repères, erreur 1,9 m (contre 3 repères et 2,2 m). Le scan du campus est placé horizontalement par la transformation inverse de `/maps/indoor/registration` (marqueurs de calibration de l’administration). Sa hauteur vient de son propre sol (`services/scan_ground.py` : 3e centile des hauteurs par maille de 60 m sur les tuiles non compressées, médiane des mailles ; `altitude_source: scan_ground`), placé au niveau 0 comme le relief : les hauteurs cliquées des repères mélangent sol et toits et laissaient le scan 2,5 m trop bas. Elles ne servent qu’en dernier recours (`altitude_source: markers`). Avec les surfaces 3D, la scène et les extrusions de MapLibre sont relevées de deux étages (6,4 m), pour que les sous-sols restent sous le sol ; personnes et signets sont dessinés par la couche 3D à la hauteur de leur étage. Là où il existe, il fait référence : le relief est masqué sous son emprise (union des enveloppes convexes des tuiles, érodée de 10 m au bord extérieur seulement pour que le relief recouvre le bord irrégulier du scan). La plupart des tuiles du scan sont compressées en Draco ; le décodeur fourni avec three.js est servi localement depuis `frontend/public/draco/`. Les deux surfaces sont rendues par une couche personnalisée three.js dans le contexte WebGL de MapLibre (`reliefLayer.ts`).

### Format et chargement

- **Cellule de relief** (`write_relief_tile`, `.bin`) : en-tête de 24 octets (`PRH1`, nombre de nœuds, taille de la cellule en mètres EPSG:3857, altitude minimale, pas vertical), altitudes sur 16 bits puis texture JPEG. Les nœuds forment une grille régulière : seules les altitudes sont stockées, en centimètres entiers au-dessus du point le plus bas, sous forme d’écarts au nœud précédent de la ligne (modulo 2^16) pour que gzip les compresse. Le client reconstruit le maillage et partage coordonnées de texture et triangles entre cellules de même taille. Transfert total : 11,4 Mo compressés (67,6 Mo avec les anciens maillages GLB), 17 Mo sur disque.
- **Ordre** : le scan est chargé en entier, puis les cellules de relief visibles (plus un quart de vue autour), des plus proches du centre aux plus lointaines, et ainsi de suite à chaque déplacement. Une cellule entièrement sous l’emprise du scan (masque érodé, comme dans le shader) n’est jamais téléchargée. Survoler ou cibler le bouton « 3D » commence ce chargement, couche masquée.
- **Cache** : `/geojson` et `/plans` portent un `ETag` (`private, no-cache`) et répondent 304 tant qu’ils n’ont pas changé ; les fichiers du scan, de l’orthophoto et du relief sont gardés un jour par le navigateur. Nginx compresse GeoJSON, cellules de relief et fichiers du scan.

## Occupation des logements

`/api/private/maps/indoor/occupancy` liste par `Location` les logements occupés (résident actuel) et libres, sans identité. La carte colore les salles liées à ces logements (plans 2D, étage extrudé en 3D, plan hors carte de U6) ; le panneau en reprend la légende et les nombres de l’étage, et la fiche d’un logement indique son statut d’après ses occupants.
