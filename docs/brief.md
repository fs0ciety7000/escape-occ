# Brief du projet — Escape from OCC

> Rempli en phase 1 de `/new-project`. Court : une page.

## Objectif
« Escape from OCC » est un jeu d'action-aventure 2D en pixel art, vue de dessus (esprit
A Link to the Past + dungeon crawler). Le joueur est enfermé dans les locaux d'OCC (bureaux,
open space) et doit s'échapper en traversant couloirs et salles, en combattant des monstres
et en récupérant badges, clés et objets qui ouvrent les accès.

Le site est un centre de contrôle / dispatching (open space multi-écrans) dans un bâtiment industriel en brique jaune avec cour intérieure.

Ton **sérieux / sombre** : ambiance tendue de bâtiment désert la nuit (néons qui grésillent,
pénombre, bruits lointains). Le décor s'inspire des locaux réels sans les copier fidèlement.

## Public
Les collègues d'OCC, dans un navigateur sur PC, au clavier (manette en bonus).
Une partie de la tranche verticale dure environ 20 à 30 minutes.

## Indispensable (v1 : tranche verticale, 1 étage)
- Déplacement 8 directions, attaque au corps à corps, esquive, points de vie, mort et reprise.
- Un étage de 6 à 10 salles reliées (open space, couloirs, salle de réunion, cafétéria,
  local serveurs…), caméra salle par salle ou défilante.
- 3 types de monstres avec des comportements distincts, et 1 boss en fin d'étage.
- Progression par objets : badge d'accès, clés, portes verrouillées, au moins un objet
  qui change la façon de jouer (ex. lampe torche pour les zones sombres).
- Écrans titre, pause, game over et fin (« sortie » de l'étage).

## Hors périmètre (v1)
- Plusieurs étages, sauvegarde persistante, multijoueur, classement en ligne.
- Contrôles tactiles et version mobile.
- Dialogues longs, cinématiques, doublage.
- Reproduction fidèle des locaux ou de personnes réelles (inspiration seulement).

## Contraintes
- Délai : environ 4 semaines pour la tranche verticale.
- Budget : nul ou faible ; assets pixel art faits maison ou sous licence libre (CC0 / CC-BY créditée).
- Hébergement : site statique interne (pas de serveur de jeu, pas de base de données).
- Compatibilité : Chrome, Firefox, Edge récents sur PC ; 60 i/s visés.
- Références visuelles : synthèse dans `docs/references/notes.md` (photos non commitées : visages et plaques visibles).

## Critères de réussite
- Un collègue qui n'a jamais vu le jeu termine l'étage sans aide en moins de 40 minutes.
- Aucun blocage de progression (soft-lock) ni crash sur un parcours complet.
- Les locaux sont reconnaissables par les collègues dans au moins 3 salles.
- Le jeu se lance depuis une URL interne en moins de 5 secondes.
