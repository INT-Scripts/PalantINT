# Brouillon : nouvelles actions de la rangée d’actions libellées

La fiche d’un lieu de `/palantint/campus` affiche sous son en-tête une **rangée d’actions libellées** (`Action` dans `CampusPanel.tsx`) : « Agenda », « Disponibilités », « Copier le lien ». Chaque action est une icône carrée avec un libellé court ; un seul geste l’exécute. Les propositions ci-dessous suivent ce format. Elles n’apparaissent que lorsque leur condition est remplie, pour ne pas ajouter de contrôle sans action utile (`DESIGN.md`).

Rien n’est implémenté. À valider avant de reporter les actions retenues dans `DESIGN.md`.

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

## Plus tard

- **Imprimer** (`Printer`) : vers `/palantint/print`, pour un point d’impression. Nécessite d’abord une correspondance serveur entre imprimantes `tsprint` et lieux ; aucune action ne doit prétendre la rendre disponible avant (voir `palantint-map-workspace.md`).
- **Laverie** : interdite dans la fiche d’un lieu par `DESIGN.md` ; elle reste dans la vue bâtiment.

## Priorité proposée

1. Voir en 3D, Emploi du temps, Réseau : pages et données existantes, aucun endpoint nouveau.
2. Profil, Association, Salle libre, Cours en cours.
3. Voisins, Recentrer, Partager, Corriger.
