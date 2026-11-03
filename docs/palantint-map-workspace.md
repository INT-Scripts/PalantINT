# Le campus comme point d’entrée de PalantINT

## Parcours livrés

- `/palantint` conserve la page d’accueil et propose un bouton compact vers `/palantint/campus`. Les liens de lieux ciblent cette page cartographique ; la vue 3D est chargée à la demande.
- La Navbar conserve ses trois menus regroupés : Campus, Annuaire, Services. L’administration dispose d’un accès dédié à côté du compte. Les sous-menus sont accessibles au clic et au clavier ; le compte reste compact. La carte occupe tout l’espace sous cette barre. La Navbar et les panneaux de carte reprennent le style PalantINT : angles droits, bordures zinc, typographie monospace et accents colorés discrets. Le bouton d’export GeoJSON et l’icône d’information 3D ont été retirés.
- Cliquer sur un bâtiment ou sa silhouette dans le sélecteur ouvre son plan. Une réglette verticale permet de choisir directement les étages ; elle reste masquée à l’échelle du campus. Les résidences donnent accès aux logements et aux laveries correspondantes. Le groupe Wemap « U1 U2 U4 » propose les résidences séparément.
- Les salles et points d’intérêt nommés ouvrent une fiche compacte superposée au plan. Les détails textuels sont repliés ; la recherche, le recentrage, les étiquettes et la bascule 3D utilisent des commandes compactes avec libellés accessibles. Celle-ci propose les occupants, associations et événements effectivement liés au lieu, avec les destinations correspondantes. Les événements ouvrent la bonne salle et la bonne date dans l’emploi du temps.
- Les murs, sols, circulations, espaces verts, portes et pièces anonymes servent de repères. Ils ne sont pas des destinations. Les points reproduisant le libellé d’une salle ne doublonnent pas son contour dans la recherche.
- Les profils étudiants et fiches d’association proposent le plan lorsqu’une correspondance unique est disponible. Les liens d’agenda et les plans historiques restent accessibles.
- La laverie privée retrouve sa présentation et sa palette `media` d’origine, conserve la résidence dans l’URL et propose un retour vers ce bâtiment sur la carte. Elle distingue les codes fournisseur `mal` et `sec` (`sl` reste accepté), utilise `machine_state` pour la disponibilité et garde les alertes de fin de cycle.

## Rendu et données

- `geojson?compact=true` retire uniquement les propriétés fournisseur inutilisées ; les identifiants et géométries sont conservés. Le format complet reste disponible sans ce paramètre.
- La requête SQL de liaison ne charge que les identifiants de lieux et les listes d’identifiants géographiques, sans matérialiser toutes les géométries stockées en base.
- La source MapLibre est mémorisée par bâtiment/étage. La recherche différée et les réponses de fiches ne la reconstruisent pas. Le survol utilise `feature-state` sans mise à jour React par mouvement de souris.
- Les étiquettes sont limitées à la fenêtre visible, au niveau de zoom et à 70 éléments ; les collisions sont écartées. Les étiquettes décoratives ne capturent ni clics ni focus clavier.
- Les données de référence et résolutions de salles sont mutualisées en mémoire pour deux minutes, avec un maximum de 128 requêtes et une séparation par jeton de connexion. Les occupants, associations et événements ne sont pas mis dans ce cache.
- Les requêtes de détail et de laverie sont annulées lors d’un changement de contexte. La laverie suspend son actualisation automatique quand l’onglet est masqué.
- Nginx compresse uniquement la réponse GeoJSON privée, sans cache partagé.

Mesures initiales, avant l’enrichissement du contrat géographique : 5 733 géométries ; réponse complète 8 460 635 octets ; réponse compacte 5 138 661 octets ; transfert gzip 921 990 octets à travers le proxy de test. La taille dépendra des extractions suivantes. Il s’agit d’une mesure de transfert, pas d’une promesse de fréquence d’images.

## Vérification

- TypeScript et lint des nouveaux composants et utilitaires.
- Compilation Next de production dans un conteneur avec les dépendances déjà installées.
- Suite backend : 42 tests, base SQLite isolée et réseau désactivé.
- `node frontend/tests/campus.test.mjs` : sélection des géométries pertinentes, catégories, liens, dédoublonnage des points de libellé, interprétation des machines. Nécessite Node avec prise en charge native des types TypeScript (Node 24 utilisé).
- Essais navigateur sur une API et une base temporaires : connexion vers l’accueil cartographique, recherche A008, sélection du sous-sol, fiche et événements liés, résidence vers laverie, retour contextuel et absence d’erreurs WebGL.

## Extensions possibles avec INT Libraries

Les paquets locaux ont été examinés sans les modifier. `intllabus` permettrait une fiche de cours depuis une occupation de salle ; `tsprint` permettrait de relier un point d’impression aux imprimantes réellement disponibles, après correspondance explicite des identifiants. Ces intégrations nécessitent leurs propres données et contrats d’authentification. Aucun bouton ne prétend les rendre disponibles aujourd’hui.

Les changements de ce chantier concernent l’espace PalantINT et son endpoint géographique privé. Le portail public conserve son interface ; les composants partagés gardent leurs valeurs par défaut pour ses pages.


## Conversion géographique vers la scène 3D

`services/map_registration.py` calcule côté serveur l’ajustement de similitude (rotation, échelle, translation) entre le repère WGS84 projeté en mètres et les empreintes de calibration enregistrées. `campusGeometry.ts` applique le transformé fourni par `/maps/indoor/registration` pour le rendu. Les marqueurs existants ne sont pas réécrits.

Le calcul utilise des noms de bâtiments correspondants sans ambiguïté. Le groupe Wemap U1/U2/U4 est associé au centroïde pondéré des empreintes des trois résidences, et non au centre d’une seule d’entre elles. Un marqueur dupliqué ou explicitement étiqueté autrement ne devient pas automatiquement un repère. Sur la calibration locale examinée : trois repères (Foyer, U7 et groupe U1/U2/U4), échelle 0,991 unité de scène par mètre, résidu RMS d’environ 2,17 m. Ce résidu décrit l’ajustement des repères, pas une précision topographique garantie ailleurs sur le campus.

`campusExtrusion.ts` convertit les anneaux en `THREE.Shape`, avec `THREE.Path` pour les trous, et extrude toutes les composantes des MultiPolygon. Les bâtiments sont des enveloppes indicatives. Le bâtiment sélectionné laisse place aux salles et circulations de l’étage choisi ; les salles nommées sont sélectionnables et proposent leurs liens réels. Le retour 2D conserve salle, bâtiment et étage.

Les niveaux utilisent une hauteur indicative de 3,2 m, avec une hauteur de pièce de 2,7 m. L’extraction ne fournit pas les altitudes de chaque plancher ni la hauteur réelle des murs. Ces volumes ne remplacent donc pas un relevé architectural ou altimétrique.

La photogrammétrie est active par défaut dans la vue 3D, avec superposition des plans en transparence ; elle peut être masquée pour isoler les plans. Au moins trois repères et un résidu inférieur à 15 m sont requis pour activer automatiquement cette superposition ; sinon la vue photo historique reste disponible. Les géométries et arêtes sont mémorisées puis libérées lors du changement d’étage/bâtiment. La scène conserve son rendu à la demande.

Vérifications supplémentaires : Les tests backend contrôlent la rotation/échelle/translation et le rejet des repères insuffisants ou ambigus ; `node frontend/tests/campusGeometry.test.mjs` vérifie l’application du transformé et la surface réelle des triangles extrudés (trous et composantes séparées conservés). Les parcours ont été essayés sur l’instance locale en mode watch fournie par l’utilisateur.


## Relations, disponibilités et correctifs de télémétrie

Le réseau privé distingue les relations renseignées, les adhésions associatives et les rattachements aux groupes pédagogiques. Le mode « Chemin » respecte le sens des relations et les filtres ; une appartenance commune n'est pas présentée comme une amitié. Les profils proposent leurs liens existants vers l'annuaire, les disponibilités, le logement et le campus.

La constellation utilise des anneaux dont le rayon et le nombre augmentent avec les éléments affichés. Il n'y a plus de pagination fixe à seize nœuds : chargement progressif, affichage de toutes les connexions du point de départ, déploiement par Maj + clic, déplacement individuel, déplacement du plan, zoom à la molette ou aux boutons et cadrage global. Les longues chaînes conservent un espacement constant et restent explorables par déplacement/zoom. La recherche porte sur tout l'index, indépendamment des nœuds actuellement dessinés. Les types symétriques « Coloc » et « Binôme » sont ajoutés par le seed de démarrage, sans écraser les réglages existants ni créer de relations entre personnes.

L'emploi du temps traite les événements qui chevauchent la période, y compris ceux commençant la veille, fusionne les occupations et bloque la sélection tant que les contraintes ne sont pas chargées. La recherche SQL des salles utilise EXISTS : DISTINCT sur une ligne Location complète échouait sous PostgreSQL à cause de la colonne JSON. Les alias de salles ne sont résolus que sans ambiguïté.

L'amphi Étoile utilise le contour de salle existant `features:indoorfeature:5782505:Polygon`, bâtiment 1346, niveau 0, et le lieu d'agenda « AMPHI Etoile 300pl ». Les géométries source restent inchangées ; la correction est appliquée à la réponse privée des plans et à la résolution des salles.

Le fournisseur de laverie bloquait pendant sa négociation TLS depuis le réseau Docker de développement. Le client annonce TCP_MAXSEG=1200 avant la connexion ; la validation du certificat et du nom d'hôte reste active. Aucun réseau Docker n'est modifié. Les requêtes simultanées sont mutualisées par résidence, le cache frais dure trente secondes et le repli sur une valeur ancienne est limité à cinq minutes. Sans valeur utilisable, une erreur 503 avec Retry-After remplace l'erreur 500 ou une fausse liste vide.

Validation de cette extension : 51 tests backend isolés, 12 tests frontend (dont une disposition de 3 000 nœuds), TypeScript, lint ciblé et build Next de production. Les derniers gestes de navigation/déplacement ne sont pas validés sur l'instance de développement : celle-ci était arrêtée lors du contrôle final.
