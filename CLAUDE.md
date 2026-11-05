# CLAUDE.md

> Lu automatiquement à chaque session. Court exprès. Les règles générales (langue, secrets, routage des skills et des agents) sont dans `~/.claude/CLAUDE.md`.

@AGENTS.md

## Projet courant

- **Type** : `gamedev-godot` + `deploy` (voir `~/.claude/skills-registry.md`)
- **Stack** : Godot 4.7.2, GDScript, rendu GL Compatibility, export Web sans threads, servi par nginx
- **Commandes** : voir `AGENTS.md` (import, dev, test, lint, build, docker)
- **Déploiement** : Coolify, mode Dockerfile (détails dans `DEPLOY.md`)
- **Skills** : `godot-*`, `game-feel`, `level-design`, `camera-systems`, `input-systems` dans `.claude/skills/` ; agents `game-designer`, `creative-coder`, `qa-tester`

## Documents du projet

- `docs/brief.md` : objectif, périmètre, contraintes.
- `DESIGN.md` : direction visuelle (couleurs, typographie, composants). À respecter pour toute interface.
- `DEPLOY.md` : cible Coolify ou Cloudflare, sous-domaine, DNS, variables (noms), retour arrière.

## Spécifique à ce projet

- Résolution interne 320×180, mise à l'échelle entière, filtre `nearest` : tout sprite est aligné sur la grille de pixels, tuiles de 16×16.
- Ton sombre, bâtiment de nuit : les lumières passent par `PointLight2D` et `LightOccluder2D`, pas par des sprites pré-éclairés.
- Décor inspiré des locaux réels (`docs/references/notes.md`), sans copie fidèle ni personne réelle reconnaissable. Les photos ne sont pas versionnées.
- Les tests n'utilisent jamais `assert()` nu (il bloque le runner headless) : passe par `assert_eq` de `tests/run_tests.gd`.
- Le web reste sans threads (pas besoin des en-têtes COOP/COEP). La version de Godot est fixée dans le `Dockerfile` (`GODOT_VERSION`) et doit rester alignée avec l'éditeur.
- Variables d'environnement : noms et rôle dans `.env.example` ; valeurs chiffrées dans `secrets/` (`kit secrets`).
