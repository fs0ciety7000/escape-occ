# AGENTS.md

Règles communes à tous les agents de code (Claude Code, Codex, Cursor...). Format neutre : rien ici n'est propre à Claude.

## Contexte

- **Nom** : Escape from OCC (`escape-from-occ`)
- **Type** : `gamedev-godot`
- **Résumé en une phrase** : jeu d'action-aventure 2D pixel art en vue de dessus (Godot 4.7, GDScript), exporté en web statique, où l'on s'échappe de nuit des locaux d'OCC.

## Commandes

```bash
install: Godot 4.7.2 (binaire `godot` dans le PATH) + modèles d'export 4.7.2 ; pip install "gdtoolkit==4.*"
import:  godot --headless --path . --import            # obligatoire après un clone (.godot/ non versionné)
dev:     godot --path . -e                              # éditeur ; `godot --path .` lance le jeu
test:    godot --headless --path . --script res://tests/run_tests.gd   # code retour ≠ 0 en cas d'échec
lint:    gdlint scripts tests && gdformat --check scripts tests
build:   godot --headless --path . --export-release "Web" build/web/index.html
docker:  docker build -t escape-from-occ . && docker run -p 8080:80 escape-from-occ
ci:      GitHub Actions (.github/workflows/ci.yml) : lint, import + tests, export web (artefact « web-build »), build Docker + /health
```

## Structure du dépôt

```
.
├── AGENTS.md
├── CLAUDE.md
├── DESIGN.md           # direction visuelle
├── DEPLOY.md           # Coolify / Cloudflare, domaine, variables (noms)
├── docs/brief.md       # objectif et périmètre
├── .env.example        # noms des variables, valeurs factices
├── docs/references/    # notes visuelles tirées des photos des locaux
├── secrets/            # secrets chiffrés (sops + age), commitables
├── project.godot       # configuration Godot (320×180, pixel art, GL Compatibility)
├── export_presets.cfg  # preset « Web » (sans threads) → build/web/
├── scenes/             # .tscn : main.tscn, rooms/, actors/, ui/
├── scripts/            # .gd : autoload/, actors/, items/
├── assets/             # sprites/, tilesets/, audio/, fonts/
├── tests/run_tests.gd  # runner de tests headless (SceneTree)
├── .github/workflows/ # CI : Godot headless sur GitHub (pas de poste local requis)
├── deploy/nginx.conf   # service statique + /health
└── Dockerfile          # build de l'export web puis nginx
```

## Règles de travail

1. Lis avant d'écrire : ouvre les fichiers concernés avant de les modifier.
2. Plus petit changement qui résout le problème. Pas de refactor non demandé.
3. Suis le style existant (nommage, formatage, structure).
4. Ajoute ou mets à jour les tests avec chaque changement de comportement.
5. Lance `test` et `lint` avant de conclure ; rapporte les résultats réels.
6. Ne touche jamais à : `.env*`, `dist/`, `build/`, fichiers de lock modifiés à la main.
7. Tâche de plus de ~5 fichiers ou changement d'architecture : propose d'abord un plan.

## Sécurité

- Aucun secret dans le code, les logs ou les commits. Les secrets passent par `kit secrets`.
- Valide toutes les entrées externes ; requêtes SQL paramétrées uniquement.
- Confirmation avant toute action destructive (suppression, reset, migration ou déploiement en prod).
