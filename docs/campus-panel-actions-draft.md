# Brouillon : nouvelles actions de la rangée d’actions libellées

La fiche d’un lieu de `/palantint/campus` affiche sous son en-tête une **rangée d’actions libellées** (`Action` dans `CampusPanel.tsx`) : « Agenda », « Disponibilités », « Copier le lien ». Chaque action est une icône carrée avec un libellé court ; un seul geste l’exécute. Les propositions ci-dessous suivent ce format. Elles n’apparaissent que lorsque leur condition est remplie, pour ne pas ajouter de contrôle sans action utile (`DESIGN.md`).

État au 2026-11-11 : les actions retenues sont livrées et consignées dans `DESIGN.md` (Agenda, Présents, Groupes ; Disponibilités, Localiser, Cercle, Même promo, Historique, Note ; Membres ; Vue immersive, Signet, Copier le lien). Les autres propositions ci-dessous restent à valider avant toute implémentation.

## Toute fiche

| Action | Icône | Condition | Effet | Données |
| --- | --- | --- | --- | --- |
| Voir en 3D | `Box` | vue Plan ou Satellite | passe en 3D, caméra cadrée sur le lieu, sélection conservée | paramètre `view` existant |
| Recentrer | `LocateFixed` | le lieu est hors de la vue | ramène la caméra sur le lieu | `bbox` du lieu |
| Partager | `Share2` | `navigator.share` disponible (mobile) | feuille de partage du système avec le lien ; sur ordinateur, « Copier le lien » reste seul | URL courante |

## Logement

| Action | Icône | Condition | Effet | Données |
| --- | --- | --- | --- | --- |
| Emploi du temps | `CalendarDays` | un seul occupant | emploi du temps de l’occupant (`timetableHref({ students })`) ; « Disponibilités » reste pour deux occupants ou plus | occupants de la fiche |
| Profil | `User` | un seul occupant | fiche étudiant `/palantint/students/{id}` | occupants de la fiche |
| Réseau | `Waypoints` | au moins un occupant | graphe centré sur l’occupant (`/palantint/network?focus=`), ou chemin entre deux colocataires (`focus` + `target`) | paramètres existants du graphe |
| Voisins | `Users` | logement d’une résidence | surligne les logements occupés du même étage sur la carte | `/maps/indoor/occupancy` |

## Salle d’enseignement (agenda)

| Action | Icône | Condition | Effet | Données |
| --- | --- | --- | --- | --- |
| Salle libre | `DoorOpen` | la salle a un agenda | ouvre l’emploi du temps sur la recherche de salles libres du créneau en cours (`day`, `start`, `end`) | `/agenda/rooms/available` |
| Cours en cours | `BookOpen` | un événement a lieu maintenant | ouvre cet événement dans l’emploi du temps, à sa date | événements du jour déjà chargés |

## Local associatif (Foyer)

| Action | Icône | Condition | Effet | Données |
| --- | --- | --- | --- | --- |
| Association | `Users` | une seule association liée | fiche de l’association (`/palantint/clubs?club=`) | `clubs` du lieu |

## Administration

| Action | Icône | Condition | Effet | Données |
| --- | --- | --- | --- | --- |
| Corriger | `PencilLine` | utilisateur administrateur | page d’administration des cartes, sur ce lieu, pour signaler ou corriger une correspondance | `location_id` |

## Pistes plus ambitieuses

Actions qui croisent la carte avec le reste de PalantINT. Chacune reste un geste unique dans la rangée ; le résultat s’affiche sur la carte ou dans le module concerné.

### Logement

| Action | Icône | Effet | Données |
| --- | --- | --- | --- |
| Localiser | `Crosshair` | la carte vole vers la salle où l’occupant a cours maintenant (ou son prochain cours, avec l’heure) | agenda étudiant, résolution des salles |
| Anciens occupants | `History` | liste chronologique des résidents passés du logement | `PersonHousing` clôturés (`ended_at`) : l’historique est déjà conservé |
| Cercle | `Waypoints` | colore sur la carte les logements de toutes les personnes liées à l’occupant (relations, colocs, même groupe) | `PersonRelationship`, adhésions, `PersonHousing` |
| Même promo | `GraduationCap` | surligne les logements de la résidence occupés par la même promo ou le même groupe de TD | `OrganizationMembership` |
| Ajouter une relation | `Link` | relation pré-remplie entre l’occupant et un voisin ou un colocataire (type « Coloc ») | relations de recherche (Vault) |
| Note | `NotebookPen` | note de recherche rattachée à l’occupant, sans quitter la carte | `Media` (journal) |
| Alerte libération | `BellRing` | prévient quand le logement devient libre | notifications existantes (laverie), à étendre au logement |

### Salle d’enseignement

| Action | Icône | Effet | Données |
| --- | --- | --- | --- |
| Qui y était | `UserSearch` | groupes et étudiants présents dans la salle à un créneau donné (par défaut : maintenant) | événements de la salle × groupes pédagogiques |
| Groupes de la semaine | `UsersRound` | les groupes qui utilisent la salle cette semaine, avec lien vers chacun | événements de la salle |
| Créneau commun | `CalendarCheck` | ouvre l’emploi du temps avec la salle et les étudiants choisis, pour trouver un créneau où tous sont libres et la salle aussi | comparaison d’agendas existante |
| Trajet du cours | `Route` | trace les logements de tous les étudiants du cours en cours vers la salle | groupes × `PersonHousing` |

### Local associatif

| Action | Icône | Effet | Données |
| --- | --- | --- | --- |
| Où vivent les membres | `MapPinned` | colore les logements des membres de l’association (bureau en premier) | adhésions × `PersonHousing` |
| Bureau | `Crown` | membres du bureau avec lien vers leurs fiches | `Organization` kind BUREAU |

### Toute fiche

| Action | Icône | Effet | Données |
| --- | --- | --- | --- |
| Épingler | `Pin` | garde le lieu en marqueur sur la carte d’une visite à l’autre, pour comparer ou revenir | état de présentation, propre à l’utilisateur |
| Vue immersive | `Eye` | caméra à hauteur d’homme dans la photogrammétrie, devant le lieu | scan 3D, `PITCH` maximal |
| Imprimer le plan | `Printer` | envoie l’étage, avec le lieu surligné, sur le compte d’impression partagé ; à retirer à n’importe quelle imprimante followme | partage d’impression (`/api/private/print`) |
| Demander à BananaBot | `Bot` | ouvre une conversation sur ce lieu (occupants, agenda, historique) | serveur MCP en lecture seule |
| QR code | `QrCode` | code du lien de la fiche, à afficher ou imprimer sur une porte | URL courante |

## Plus tard

- **Imprimer** (`Printer`) : vers `/palantint/print`, pour un point d’impression. Nécessite d’abord une correspondance serveur entre imprimantes `tsprint` et lieux ; aucune action ne doit prétendre la rendre disponible avant (voir `palantint-map-workspace.md`).
- **Laverie** : interdite dans la fiche d’un lieu par `DESIGN.md` ; elle reste dans la vue bâtiment.

## Priorité proposée

1. Voir en 3D, Emploi du temps, Réseau : pages et données existantes, aucun endpoint nouveau.
2. Profil, Association, Salle libre, Cours en cours.
3. Voisins, Recentrer, Partager, Corriger.
