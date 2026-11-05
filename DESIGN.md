# DESIGN.md — direction « Alerte rouge »

> Direction visuelle d'Escape from OCC, lue par les agents de design et de jeu. Choisie en phase 4
> (direction B). Maquette de référence : https://claude.ai/artifact/Y9bde2Tqp1PQGm1Z8PuXwA.
> Le jeu est entièrement nocturne : pas de thème clair/sombre, une seule ambiance déclinée par salle.

## Principes

1. **Le bâtiment est en confinement.** Les gyrophares rouges et les néons d'urgence orange font la lumière. Le décor est éclairé, mais teinté.
2. **La lecture d'abord.** Le joueur, les ennemis, les objets et les portes se distinguent en moins d'une seconde, même en plein balayage rouge.
3. **La couleur porte un sens** (voir Couleurs). Le cyan est réservé à ce qu'on peut ramasser ou activer : on ne l'utilise jamais pour le décor.
4. **Des locaux reconnaissables, pas copiés.** Brique jaune, cloisons bleues, postes multi-écrans, plafond à dalles, cour pavée et quai de chargement (`docs/references/notes.md`).
5. **Le pixel est net.** Résolution 320×180, tuiles de 16×16, mise à l'échelle entière, aucun lissage, aucune rotation de sprite hors de la grille.

## Couleurs

Palette maîtresse de 24 couleurs au plus. Les assets achetés ou libres sont recolorés vers elle, ou harmonisés par `CanvasModulate` et la lumière.

| Rôle | Couleur | Usage |
|---|---|---|
| Nuit (fond, vide) | `#160B0B` | hors champ, fond des menus |
| Ombre | `#1A0606` | couleur des zones non éclairées |
| Béton | `#3D3434` | murs bas, socles, plinthes |
| Carrelage | `#8F8A8A` / joints `#726D6D` | sols de l'open space |
| Brique | `#C9B37A` / ombre `#A8935E` / joint `#8F7C4D` | murs (façade jaune pâle) |
| Cloison | `#2E5AA8` / ombre `#1F3A6B` / reflet `#4D78C4` | cloisons des postes |
| Mobilier | `#2B2D33` / `#121318` | bureaux, écrans éteints, chaises |
| **Gyrophare / danger** | `#FF3B2F` | alarme, dégâts, écrans « LOCKED », zones mortelles |
| **Urgence** | `#FF8A1F` | néons d'urgence, points de vie |
| **Alerte (interface)** | `#F2C230` + `#121212` | bandeaux d'alerte, cadres de l'interface, clés |
| **Objet / interaction** | `#3FD0D4` | badges, objets à ramasser, terminaux activables |
| Monstre | `#8E3FA8` / ombre `#5A2470` / reflet `#B765CF` | corps des ennemis (teinte par famille possible) |
| Yeux, points faibles | `#FFE14A` | yeux des monstres, points faibles du boss |
| Sortie, réussite | `#4FCB6B` | portes déverrouillées, bloc de sortie, sauvegarde |
| Joueur | `#3B4252` / reflet `#4C556A`, peau `#D9A27E` | silhouette froide, qui ressort sur le rouge |
| Texte | `#E6E2D6` sur `#121212` | dialogues, menus |

Règles de couleur :
- **Contraste** : le texte `#E6E2D6` sur `#121212` donne environ 14:1, et le jaune `#F2C230` sur `#121212` environ 11:1. Minimum 4,5:1 pour tout texte.
- **Daltonisme** : le danger n'est jamais signalé par le rouge seul. Il s'accompagne d'une forme (hachures, contour, icône) ou d'un son.
- **Objets** : un objet à ramasser porte toujours du cyan, plus une petite lueur (`PointLight2D`, rayon d'environ 18 px).

## Lumière

- Rendu GL Compatibility. Un `CanvasModulate` par salle fixe l'ambiance de base (environ 30 % de luminosité, teinte rouge sombre).
- Gyrophare : un `PointLight2D` en cône rouge qui tourne en 2,5 s par tour (0,4 Hz). Il projette les ombres des cloisons et des bureaux via `LightOccluder2D`.
- Néons d'urgence : des `PointLight2D` orange fixes le long des murs, rayon d'environ 48 px.
- Écrans : une petite lueur rouge (rayon d'environ 16 px), avec un sprite émissif non affecté par l'ombre.
- **Clignotements : jamais plus de 3 par seconde.** Une option « réduire les flashs » fige les gyrophares et atténue les secousses d'écran.
- Respiration du rythme : une salle calme par séquence (cafétéria, cage d'escalier), éclairée seulement en orange, sans gyrophare.

## Typographie

- Polices pixel bitmap, rendues à la taille native ou à un multiple entier. Pas de lissage.
- **Titres et bandeaux** : une police pixel condensée de 8 à 10 px de haut, en capitales.
- **Texte et dialogues** : une police pixel lisible de 8 px de haut, avec les accents français (é è à ç ô œ « »).
- Police retenue : **m5x7** (Daniel Linssen, CC0), à utiliser en 16/32/48 px d'écran. Les accents é è à ç sont à vérifier dans Godot ; si un glyphe manque, on passe à une autre police pixel OFL ou CC0.
- Échelle (en pixels internes) : 8 pour le texte, 10 pour les titres de menu, 16 pour le logo et l'écran titre.

## Grille, espacements, contours

- Tuile de 16×16. Personnages de 16×16 (ou 16×24 pour le boss et les grands ennemis).
- Marges de l'interface : 4 px du bord de l'écran, 2 px entre les éléments, cadres de 1 px.
- Contour sombre de 1 px (`#121212`) sur le joueur, les ennemis et les objets. Le décor n'en a pas, ce qui sépare clairement le premier plan.
- Pas de dégradés lissés dans les sprites. Les ombres portées au sol sont des ellipses de 2 px en `#000` à 50 %.

## Composants (interface)

- **Barre d'interface du haut** : bandeau d'alerte jaune et noir hachuré, de 6 px. Les points de vie sont des blocs orange à gauche. À droite, le badge et les clés (icônes, plus un compteur).
- **Boîte de dialogue** : fond `#121212`, cadre jaune de 1 px, texte `#E6E2D6`, nom du locuteur en jaune.
- **Menus** (titre, pause, game over) : liste verticale. L'élément sélectionné est préfixé d'un curseur jaune et surligné en `#2B2D33`. La navigation se fait au clavier et à la manette, avec le focus toujours visible.
- **États** :
  - porte verrouillée : rouge, avec l'icône de l'objet requis ;
  - porte ouverte : vert ;
  - terminal activable : cyan qui pulse lentement ;
  - désactivé : gris `#3D3434`.
- **Écran de game over** : la teinte passe au rouge, puis le texte « CONFINEMENT MAINTENU » s'affiche.

## Mouvement et game feel

- Animations de 4 à 8 images à 8–12 i/s pour les personnages.
- Coup porté : 2 à 3 images de gel (hit-stop), un recul de 4 à 6 px, la cible qui clignote en blanc 1 image sur 2 pendant environ 0,3 s.
- Secousse d'écran : 2 px au maximum, et seulement sur les dégâts reçus ou le boss. Désactivable.
- Transitions de salle : glissement de caméra de 0,4 s, en ease-out, comme dans A Link to the Past.
- Paramètre d'accessibilité : « réduire les flashs et les secousses ».

## Sources d'assets

| Usage | Pack | Licence | Règle |
|---|---|---|---|
| Décor de bureau, murs, sols, personnages | LimeZu, Modern Office Revamped + Modern Interiors (itch.io, payants) | LimeZu : crédit obligatoire, revente et redistribution interdites | Versions 16×16 uniquement. Les fichiers ne vont jamais dans un dépôt public. Crédit dans l'écran des crédits. |
| Monstres, boss, effets, icônes, musique | Pixel-boy, Ninja Adventure | CC0 | Seulement les monstres, les effets, les icônes et l'audio (pas les tuiles fantasy). Recolorés vers la palette ci-dessus. |
| Bruitages d'alarme et d'interface | Kenney, Sci-fi Sounds + Interface Sounds | CC0 | — |
| Police | m5x7 | CC0 | — |
| Ruban de danger, gyrophares, cour pavée, quai de chargement | faits maison | — | Dessinés dans la palette. |

- Tous les humains (joueur et PNJ) viennent d'une seule famille de sprites, pour garder les mêmes proportions.
- Chaque asset tiers est noté dans `assets/CREDITS.md` : nom, auteur, URL, licence.
