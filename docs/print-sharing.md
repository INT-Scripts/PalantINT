# Partage de quota d’impression (followme)

Un membre PalantINT (le **donneur**) permet à d’autres membres d’imprimer sur son propre compte followme (PaperCut). PalantINT se connecte à followme avec les identifiants CAS du donneur (`UserCredential`, fournisseur `CAS`, chiffrés Fernet). Il téléverse le PDF du demandeur et le laisse en attente. Le demandeur choisit ensuite une imprimante et libère le document à distance.

## Constats followme (relevés le 2026-11-03)

Relevés avec `int-libraries/packages/tsprint/tests/discover.py`, en lecture seule.

- Le solde et tous les coûts sont exprimés en **pages** (`1 072 page(s)`). Toutes les valeurs du partage sont des entiers en pages.
- Files d’impression web :
  - index 0 : `FollowMe-Students` (noir et blanc) ;
  - index 1 : `FollowMe-Students-Color`.
- Tarifs de ces files : 1 page par page en noir et blanc, 8 en couleur, 6 en couleur recto-verso. Les copieurs physiques sont à 0.
- La couleur est facturée page par page selon le contenu : 8 pages dont 7 en couleur coûtent 57.
- L’étape « options » de l’impression web ne propose que le nombre de copies. Le recto-verso ne se règle pas par le web.
- Les transferts de crédit (`UserTransfers`) n’existent pas sur ce serveur, et `UserSharedAccounts` est vide. Imprimer sur le compte du donneur est donc le seul modèle possible.

## Règles

- **Modes de partage**, par donneur :
  - autorisations nominatives (`PrintGrant`) ;
  - partage ouvert à tous les membres, avec une limite par personne.
- **Une impression doit respecter toutes les limites** : autorisation ou limite par personne, plafond total du donneur, et solde followme diminué des réservations en cours, qui doit rester au-dessus du solde à conserver.
- **Validation** automatique ou manuelle, au choix du donneur. Une demande manuelle expire au bout de 24 h.
- **Réservation** : pages × copies × tarif de la file (8 en couleur, soit le pire cas). Le montant est ajusté au coût réel lu dans l’historique followme une fois le document libéré.
- **Attente** : un document non libéré est annulé au bout d’une heure. Le demandeur est prévenu 10 minutes avant.
- **Consommation** : elle n’est jamais stockée comme compteur. Elle est la somme des `PrintRequest` en cours (estimation) ou rapprochées (coût réel).
- **Retrait d’une autorisation** : il annule les documents en cours pour cette autorisation. La suspension bloque les nouvelles impressions, les validations et les libérations.
- **Fichiers** : PDF uniquement, 50 Mo au plus. Le fichier est supprimé dès son envoi à followme ou à la fin de la demande.
- **Identifiants refusés par followme** : seule la demande concernée échoue. Le partage n’est pas suspendu.

## Cycle de vie (`PrintRequest.status`)

`PENDING_APPROVAL` → `APPROVED` → `UPLOADING` → `HELD` → `RELEASED` → `RECONCILED`, ou `CANCELLED`, `REJECTED`, `EXPIRED`, `FAILED`.

Le document est nommé `palantint-<8 premiers caractères de l’identifiant>-<nom>.pdf` dans followme. Ce nom est la seule prise utilisée pour retrouver, libérer, annuler ou rapprocher le travail. Les travaux personnels du donneur ne sont jamais touchés.

## Code

| Élément | Emplacement |
|---|---|
| Client followme | `int-libraries/packages/tsprint` (`get_rates`, `get_print_options`, `upload_file(filename=…)`, valeurs typées des historiques) |
| Modèles | `PrintShareSettings`, `PrintGrant`, `PrintRequest` dans `backend/src/db/models.py`, migration `a3d5e7f9b1c2` |
| Service | `backend/src/services/printing/` : `session.py` (session followme par donneur, verrou), `quota.py` (règles), `jobs.py` (cycle de vie), `loop.py` (tâche de fond lancée au démarrage) |
| API | `backend/src/api/private/printing.py`, sous `/api/private/print/*` ; l’administration sous `/print/admin/*` |
| MCP | `get_print_sharing_stats` : totaux uniquement, sans documents ni noms |
| Interface | `/palantint/print` (Imprimer, Mes partages, Historique) et `/palantint/admin/print` ; accent `print` (citron vert) |
| Réglages | `PRINT_*` dans `backend/src/core/config.py` (délais, taille maximale, dossier temporaire `private_assets/print_uploads`) |

L’image backend reçoit `int-libraries` comme contexte de build supplémentaire (`compose.yaml`). `tsprint` y est installé depuis `/int-libraries/packages/tsprint`, ce qui correspond au chemin `../int-libraries` de `backend/pyproject.toml`.

## Pistes non réalisées

- Afficher les imprimantes sur `/palantint/campus`. Cela demande une correspondance explicite entre imprimante et lieu, dans le référentiel serveur des lieux.
