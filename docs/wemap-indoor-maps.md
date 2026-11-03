# Plans géographiques privés du campus

La page `/palantint/campus` utilise des plans GeoJSON WGS84 (RFC 7946), indépendants du SDK Wemap. La vue 3D existante reste accessible dans un second onglet. Les plans de logements et du Foyer, désormais convertis en GeoJSON avec géométrie locale, conservent leurs calibrations et leurs correspondances historiques ; des liens permettent d’ouvrir le bâtiment dans la carte géographique.

## Extraction

Le nouveau domaine **Plans intérieurs du campus (Wemap)** est disponible dans le pipeline `palantint sync`, séparément pour la collecte et l’ingestion. La collecte ne demande ni CAS ni base de données.

```bash
# Depuis le dépôt, sur l’hôte.
cd scripts
uv run palantint # Interface interactive : sélectionner le domaine Wemap.

# Extraction directe.
uv run palantint-wemap

# Reconstruire les mêmes plans à partir des réponses et tuiles archivées.
uv run palantint-wemap --offline

# Charger les lieux dans la base déjà démarrée.
uv run python -m palantint_scripts.loaders.wemap
```

`palantint wemap` accepte aussi `--map-id`, `--zoom`, `--concurrency` et `--offline`. Le zoom par défaut est le maximum natif annoncé par la source. Les téléchargements utilisent au plus cinq connexions par défaut et réessayent les erreurs transitoires. Les fichiers bruts sont archivés pour permettre une reconstruction sans accès au fournisseur.

Les chemins sont centralisés dans `palantint_scripts.config` :

- `WEMAP_DIR` : `data/scraps/auto/wemap/`, avec réponses brutes, tuiles PBF, manifeste et `campus.geojson`.
- `WEMAP_IMPORT_DIR` : `data/scraps/manual/wemap/`, pour les exports fournis initialement.
- `GEO_PLANS_DIR` : `data/private_assets/maps/`, avec le GeoJSON consulté par l’API privée.

Le répertoire privé est déjà monté dans le service backend. Aucun plan enrichi ni aucune identité d’occupant ne sont publiés sous `/assets`.

## Ce que l’extracteur conserve

La carte `29608` référence une source de plans vectoriels distincte des points d’intérêt. L’extracteur découvre cette source à partir du style de la carte, télécharge toutes les tuiles couvrant son emprise au zoom natif, puis assemble les fragments par identifiant source. Il conserve les anneaux intérieurs des polygones, les lignes, les points, les étages multiples et les métadonnées d’origine.

Les noms, descriptions, catégories, horaires, liens et médias sont joints par identifiant Wemap. Les points sans contour sont conservés comme points ; les pièces sans nom restent sans nom. Aucun contour n’est déduit d’un point et aucune association de local n’est créée par simple proximité. Les surfaces affichées sont des estimations calculées sur les contours géographiques, pas les surfaces contractuelles Maisel.

L’extraction initiale vérifiée comprend 90 tuiles demandées (dont 36 vides), 5 733 géométries, 1 925 contours de salles, 18 ensembles de bâtiments et 1 192 points d’intérêt. Les nombres évoluent avec la source. Wemap regroupe notamment U1/U2/U4 en un seul bâtiment et ne fournit pas de nom pour toutes les pièces. Les plans historiques restent utiles là où la source ne fournit pas le détail attendu.

## Ingestion et provenance

Le loader utilise `DataSource(code="wemap")` et journalise chaque invocation dans `IngestionRun`. `Location.source_id` identifie les lieux créés par l’import. Leurs métadonnées et géométries Wemap restent dans `Location.attributes.wemap`, afin de préserver les autres champs, les identifiants, les occupants, les événements et les calibrations.

Les bâtiments et étages sont réutilisés lorsqu’ils correspondent sans ambiguïté. Les appartements Maisel gardent leur parent direct BUILDING, dont dépendent les API existantes. Deux pièces distinctes portant le même nom restent distinctes. Une disparition de la source archive la géométrie ; elle ne supprime ni les données de logement ni les événements liés.

La migration Alembic `f1c02d3a4b56` ajoute la provenance des lieux. L’initialisation du backend applique également cet ajout de colonne de façon idempotente, selon le mécanisme de compatibilité déjà utilisé par le projet.

## API privée

- `GET /api/private/maps/indoor/manifest` : bâtiments, étages et statistiques de provenance.
- `GET /api/private/maps/indoor/geojson` : collection GeoJSON, avec filtres facultatifs `building` et `level`.
- `GET /api/private/maps/indoor/lookup?q=...` : correspondance exacte d’un code de salle avec sa géométrie.
- `GET /api/private/maps/indoor/locations/{id}` : contexte privé du lieu, occupants et associations liés, prochaines occupations d’agenda.

Les URL de carte acceptent `building`, `level`, `feature` ou `room`. Un bouton dans l’emploi du temps ou le détail d’un événement ouvre le plan uniquement lorsqu’une correspondance unique est disponible. La carte fonctionne sans appel au SDK ni aux tuiles Wemap pendant la consultation : elle utilise les géométries extraites localement.

## Vérification

Les tests couvrent la couture des tuiles, les trous des polygones, la pagination complète, les niveaux fractionnaires, les points sans contour, la répétabilité de l’import, la préservation des logements et des événements, ainsi que l’authentification et l’absence de routes publiques pour les plans privés.
