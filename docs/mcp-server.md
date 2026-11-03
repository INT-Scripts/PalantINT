# Serveur MCP PalantINT

Le serveur MCP expose l’espace privé de PalantINT en lecture seule à des agents, principalement BananaBot.

## Accès

* **Endpoint** : `/api/mcp/` (transport streamable HTTP), monté dans `backend/src/main.py`.
* **Authentification** : jeton porteur `MCP_SERVICE_TOKEN`. Les échecs sont limités par IP (`core/rate_limit.py`, `mcp_auth_limiter`).
* **Données** : les outils appellent l’API privée en boucle locale (`MCP_API_BASE_URL`, par défaut `http://localhost:3000/api/private`) avec ce même jeton.
* **Côté BananaBot** : déclarer un serveur MCP avec `url` et l’en-tête `Authorization: Bearer <MCP_SERVICE_TOKEN>`. Les schémas sont relus à chaque connexion.

## Code

`backend/src/palantint_mcp/` :

| Fichier | Rôle |
|---|---|
| `server.py` | Instance FastMCP, vérification du jeton, consignes (`GUIDE`), enregistrement ordonné des outils |
| `client.py` | Client de l’API privée : erreurs reformulées pour le modèle, caches, résolution des étudiants, clubs et groupes |
| `inputs.py` | Types de paramètres documentés, validation des dates (heure de Paris) |
| `format.py` | Rendu texte compact, pagination (`page`), troncature signalée (`clip`) |
| `tools/*.py` | Outils par domaine : annuaire, emplois du temps, clubs, logement, impression |

Tests : `backend/src/tests/test_mcp_tools.py`.

## Outils

Dans l’ordre où ils sont présentés au modèle :

| Outil | Usage |
|---|---|
| `get_student` | Profil, réseaux, relations ou notes d’un étudiant (identifiant TrombINT ou nom complet) |
| `search_directory` | Recherche d’étudiants, clubs et groupes ; parcours par promo, école ou bâtiment |
| `get_student_schedule` | Cours d’un étudiant sur une journée, avec salles |
| `where_is_student` | Salle de cours à un instant, sinon logement |
| `find_common_free_slots` | Créneaux libres communs entre 08:00 et 20:00 |
| `get_club` | Détails d’un club, ou bureau et membres |
| `get_class_roster` | Membres d’un groupe de classe |
| `find_shortest_path` | Plus courte chaîne de liens entre deux étudiants |
| `get_room_schedule` | Occupation des salles sur une période |
| `find_available_rooms` | Salles libres sur un créneau |
| `get_apartment_info` | Caractéristiques d’un logement Maisel |
| `get_laundry_status` | Machines libres et occupées (service externe, en direct) |
| `get_print_sharing_stats` | Totaux du partage de quota d’impression (donneurs, autorisations, pages), sans documents ni noms |
| `list_reference` | Valeurs admises : salles, bâtiments, promos, écoles, types de relations |

## Conventions (alignées sur BananaBot)

* **Description** : ce que fait l’outil et quand l’utiliser, sur une ligne. Chaque paramètre est documenté une seule fois, dans le schéma (`Annotated[..., Field(description=...)]`), avec exemple, défaut et limites. Les limites annoncées sont celles appliquées par le code.
* **Annotations** : tous les outils déclarent `readOnlyHint`. La laverie est `openWorldHint` et dispose d’un délai plus long.
* **Ordre** : l’ordre d’enregistrement dans `server.py` est celui vu par le modèle. Les outils les plus courants viennent en premier.
* **Consignes serveur** : `GUIDE` sert à la fois de prompt `tool_guide` et d’`instructions`. BananaBot l’ajoute à chaque description d’outil et le tronque à 400 caractères ; le garder sous 300.
* **Erreurs ou réponses** :
  * Une entrée invalide (date mal formée) ou une panne de l’API lève une `ToolError`. Le message indique s’il faut réessayer.
  * Un nom introuvable ou ambigu est une réponse normale, qui propose l’étape suivante. Ainsi, une faute de frappe ne fait pas désactiver l’outil par le disjoncteur de BananaBot.
* **Listes** : toujours plafonnées. Une liste coupée se termine par `(more: call outil(..., offset=N) or narrow the query)`. L’ordre est stable d’un appel à l’autre.
* **Heures** : heure locale de Paris, sans fuseau, comme dans l’emploi du temps.
