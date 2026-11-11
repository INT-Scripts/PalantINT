# Autorité des données et pipeline du campus

Les identités, relations, correspondances de lieux et calibrations appartiennent au serveur. Le client garde uniquement l’état de présentation : sélection, recherche, caméra, positions temporaires du graphe et paramètres d’URL. Les caches mémoire de réponses API ne sont pas une source de données indépendante.

## Référentiel des plans historiques

`backend/src/core/map_reference.json` versionne les définitions initiales des bâtiments, étages, libellés, chemins GeoJSON et règles de correspondance du logement. Le seed crée les métadonnées dans `Location.attributes.legacy_plan`, avec la source `campus_reference` pour les nouveaux lieux. Il complète les champs absents sans écraser une configuration existante.

`GET /api/maps/catalog` projette uniquement les catégories de plans, valeurs d’étages, libellés, chemins de ressources et bâtiments de laverie. Il ne publie ni occupants ni attributs libres des lieux. Les endpoints historiques `/api/maps/buildings` et `/api/private/maps/buildings` utilisent la même projection.

Les vues de logement, foyer, associations, laverie et les deux interfaces de calibration chargent le catalogue via `BuildingCatalogBoundary`. Aucune copie des listes d’étages ou des conventions de fichiers U5/Foyer ne demeure dans le client. En cas d’échec, un état explicite permet de réessayer ; aucune liste locale ne masque un problème serveur.

L’ingestion Maisel écrit `Location.attributes.plan`. Les réponses publiques et privées du logement partagent la même projection et fournissent `plan.building` et `plan.floor`. Pour les données déjà importées sans ce champ, la même normalisation serveur assure la compatibilité. Le filtrage et la sélection du client utilisent ces valeurs, y compris les deux demi-niveaux d’U5. Les valeurs d’étage des anciens plans ne sont pas envoyées comme des niveaux Wemap : un lien vers une salle résout son contexte géographique via le serveur, et un lien vers un bâtiment ouvre ce bâtiment.

## Plans géographiques et curation

Le scrape conserve l’extraction géographique originale. Le loader `wemap` applique les règles versionnées et, le cas échéant, les règles locales de `SCRAPS_MANUAL_DIR / metadata / wemap-curations.json`. Les constantes de chemins viennent de `palantint_scripts.config`.

Chaque règle comporte un identifiant, un `source_code` enregistré dans `DataSource`, une justification, les `feature_ids`, le `primary_feature_id`, les propriétés corrigées, les alias et la cible canonique `location` (`kind` et `name`). Les règles locales complètent ou remplacent les règles versionnées pour les géométries concernées.

La correction Étoile relie le contour existant et ses points de libellé à la salle d’agenda existante. Elle ne crée aucun contour et ne fusionne ni ne supprime les identités précédentes. Une cible ambiguë fait échouer l’import. Le loader conserve les autres attributs et les références d’agenda/logement/recherche ; la provenance de curation (`source_code`, `source_id`, justification) reste dans `Location.attributes.wemap.curation` et le passage est audité par `IngestionRun`.

L’API privée superpose les propriétés persistées à la géométrie source. Elle ne contient aucune exception Étoile. Elle refuse une géométrie liée à plusieurs lieux actifs plutôt que de choisir arbitrairement une identité. La catégorie, la sélection des destinations et le dédoublonnage des points de libellé sont décidés côté serveur. Un point ambigu n’est pas supprimé de la navigation par simple supposition.

Les alias de salles sont normalisés côté serveur pour le plan et l’agenda. Les alias explicitement déclarés par une curation réunissent les occupations et les liens contextuels d’anciens lieux sous la salle canonique, sans modifier leurs identifiants ni leurs événements. L’ingestion d’agenda réutilise cette même correspondance pour les prochains événements. Une correspondance ne traverse pas un parent d’étage différent. `/api/private/agenda/rooms/resolve` renvoie un libellé canonique unique ou signale l’ambiguïté. `/api/private/maps/indoor/lookup` compte une seule fois les enregistrements d’une même entité ; entre entités distinctes, l’enregistrement portant exactement le libellé d’agenda, puis celui rattaché à un étage, l’emporte. Un libellé sans correspondance de nom se rabat sur son unique code de salle (« Salle B313 » → B313) ; une égalité restante est renvoyée telle quelle et le client n’affiche aucun lien. Les limites de disponibilité et l’affichage des intervalles restent des calculs de présentation à partir des événements reçus.

Après une modification de curation, relancer le domaine Wemap dans `uv run palantint`, depuis `scripts/`, ou exécuter `uv run python -m palantint_scripts.loaders.wemap`. L’interface ne modifie jamais silencieusement les correspondances pour compenser une ingestion manquante.

## Alignement 3D

`GET /api/private/maps/indoor/registration` calcule l’alignement à partir des empreintes géographiques et des marqueurs de calibration enregistrés en base ou dans le Vault existant. Le serveur exige des correspondances non ambiguës, au moins trois repères et une erreur RMS au plus égale à 15 m. Le client reçoit le transformé ou `null` et applique uniquement les calculs de projection/extrusion pour le rendu. Les marqueurs et les géométries source ne sont pas réécrits par ce calcul.

## Relations dérivées et recherche manuelle

Le service partagé `services.relationships.roommate_links` déduit les colocations des rattachements de logement actifs. Les profils et le graphe utilisent les mêmes identifiants et indiquent `derived: true`, `origin: housing`. Ces liens ne deviennent pas des lignes de recherche manuelle. Une relation Coloc déjà renseignée évite le doublon dérivé. Fermer un rattachement retire son lien dérivé sans effacer la recherche ; l’interface ne propose pas de supprimer directement un lien calculé.

Les types symétriques Coloc et Binôme sont créés par le seed et conservés en base. Les groupes pédagogiques et adhésions restent des rattachements explicites ; ils n’inventent pas de relations personnelles.

## Sauvegarde et vérification

Le Vault inclut désormais `map_references.json`, qui contient les métadonnées de plans et les règles locales de curation. La restauration des métadonnées conserve les autres attributs des lieux. Un fichier local de curation déjà présent reste prioritaire ; la restauration ne recrée ce fichier que s’il manque. Les règles versionnées sont conservées dans le dépôt.

Les tests couvrent la projection publique, la conservation des personnalisations, les alias ambigus, les colocations communes au profil/graphe, les règles U5, la sélection des destinations, l’alignement 3D et un parcours extraction → ingestion répétée → API avec conservation des géométries, identités, notes et références d’agenda. Le round-trip du Vault couvre les nouvelles métadonnées et protège les règles locales plus récentes.
