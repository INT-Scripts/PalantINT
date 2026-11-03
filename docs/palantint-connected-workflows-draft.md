# Ébauche — rendre les parcours PalantINT continus

## Point de départ vérifié

Des liens utiles existent déjà dans l'interface :

| Parcours | État actuel |
| --- | --- |
| Logement ↔ fiche étudiante | Le logement ouvre la fiche de l'occupant ; la fiche ouvre le logement avec `?room=`. |
| Association → membre et local | La fiche de l'association ouvre les membres et son local dans le Foyer avec `?room=`. |
| Local du Foyer → association | Le détail du local ouvre la fiche de l'association. |
| Graphe → personne ou association | Un clic sur un nœud ouvre la fiche ou la modale correspondante. |
| Fiche étudiante → classe, relations, agenda | Ces données sont accessibles depuis la fiche ; les classes et relations ouvrent leurs fiches. |
| Campus → bâtiment résidentiel | La carte ouvre les logements filtrés par bâtiment. |
| Recherche globale → fiches | La barre du haut recherche déjà personnes, associations, classes et logements. |

Ces liens ne sont pas à reconstruire. Le problème restant est surtout la **perte de contexte** lorsqu'on passe d'une capacité à l'autre.

Un défaut concret ressort aussi de l'audit : la recherche globale construit des URL `/clubs/<id>`, alors que les associations s'ouvrent aujourd'hui dans une modale sur `/clubs` ou `/palantint/clubs`. Elle construit également `/class-groups/<id>` côté public, où cette route n'existe pas. Ces destinations sont à corriger dans la recherche existante.

## Proposition prioritaire : un contexte de travail partageable

L'emploi du temps est le meilleur premier cas. Il permet de sélectionner plusieurs personnes, une salle, une semaine et une plage horaire, mais la sélection vit uniquement dans l'état de la page. Un retour depuis une fiche, un rechargement ou un partage oblige à tout ressaisir.

1. **Mettre l'état utile dans l'URL.** Accepter par exemple `?students=<id>,<id>&room=<nom>&week=YYYY-MM-DD&start=HH:mm&end=HH:mm`. Garder les dates et heures lisibles. Les personnes ont déjà des ID stables ; l'API d'agenda expose encore les salles par libellé. Utiliser ce libellé tant qu'elle ne fournit pas d'ID de `Location`, puis migrer l'URL. Ne sérialiser que des sélections valides.
2. **Ouvrir l'emploi du temps dans le bon contexte.** Depuis l'agenda d'une personne, proposer « Comparer les disponibilités » avec cette personne et la semaine affichée. Depuis le détail d'un événement, proposer « Vérifier cette salle » avec la salle et la semaine de l'événement. Les fiches et liens existants restent en place.
3. **Permettre le retour vers la source.** Dans le sélecteur de l'emploi du temps, le nom d'une personne ouvre sa fiche. Après consultation, le bouton Retour retrouve la comparaison grâce à l'URL. Si une salle possède un emplacement cartographié, proposer « Voir sur le plan » ; sinon ne pas afficher ce lien.
4. **Ajouter une synthèse transversale légère.** À côté d'un créneau retenu, montrer pourquoi il est libre : personnes sélectionnées, salle éventuelle et plage exacte. Les salles libres renvoyées par l'API servent de choix directs. Cette synthèse peut être copiée comme lien interne pour un autre utilisateur autorisé.

## Suite possible après validation du premier parcours

- **Enrichir la recherche globale existante.** Vérifier que chaque résultat ouvre une destination valide, puis ajouter les actions secondaires pertinentes, comme « Comparer l'agenda » pour une personne ou « Voir le local » pour une association. Garder l'ouverture de la fiche comme action principale.
- **Espace de comparaison temporaire.** Permettre d'ajouter une personne depuis sa fiche ou le graphe à une comparaison d'emploi du temps en cours. Préserver la liste dans l'URL ou dans un état de session, avec un indicateur visible et une action « Comparer ».
- **Liens vers un état précis d'une vue.** Étendre progressivement le modèle d'URL existant pour sélectionner un club dans `/palantint/clubs` ou une personne dans `/palantint/network`, si ces usages sont fréquents. Mesurer d'abord les recherches répétées.

## Ordre de livraison proposé

1. URL de l'emploi du temps et restauration fiable de ses sélections.
2. Entrées contextuelles depuis l'agenda et le détail d'un événement.
3. Retour depuis l'emploi du temps vers les fiches ; lien vers le plan seulement si l'emplacement est connu.
4. Enrichissement de la recherche globale existante ou espace de comparaison selon les usages observés.

## État de cette première mise en œuvre

- L'emploi du temps restaure la semaine, les personnes, la salle et le créneau depuis l'URL ; chaque changement met le lien à jour.
- L'agenda d'une personne ouvre la comparaison sur sa semaine. Le détail d'un événement peut ouvrir la comparaison avec sa salle.
- Les personnes sélectionnées dans la comparaison ouvrent leur fiche, et un lien vers la sélection peut être copié.
- La recherche globale ouvre les associations dans la modale existante et offre une action « Comparer » pour les personnes connectées.
- Le lien salle → plan reste à traiter : les salles de l'agenda sont encore exposées par libellé et aucun rattachement fiable aux plans n'a été établi dans cette vue.

## Critères de validation

- Une URL copiée restaure la même semaine, les mêmes personnes, la même salle et le même créneau pour un utilisateur connecté.
- Depuis un événement, l'emploi du temps s'ouvre sur la bonne semaine et la bonne salle sans ressaisie.
- Le parcours aller retour entre comparaison et fiche conserve les sélections.
- Les URL privées utilisent des identifiants et restent protégées par l'authentification existante ; aucun nom d'occupant n'apparaît dans les réponses publiques.
