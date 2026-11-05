# DEPLOY.md

> Plan de déploiement du projet. Aucune valeur secrète ici : noms de variables seulement. Voir le skill `deploy-coolify-cloudflare`.

## Cible

- **Plateforme** : Coolify (VPS), site statique servi par nginx.
- **Source Git** : `fs0ciety7000/escape-occ`, branche de production `main`. Pas de préproduction : le travail passe par une PR vers `main`. Coolify réutilise la GitHub App ou la clé de déploiement des autres applications (à lire via `kit api coolify /github-apps` et `/security/keys`).
- **Mode de build** : Dockerfile (`./Dockerfile`), en multi-étapes :
  1. Debian télécharge Godot `GODOT_VERSION` (4.7.2) et les modèles d'export web, puis lance `--import` et `--export-release "Web"` ;
  2. l'image finale est `nginx:1.27-alpine`, avec `deploy/nginx.conf`.
- **Port d'écoute** : 80 (conteneur).
- **Route de santé** : `GET /health` → `200 ok` (plus le `HEALTHCHECK` Docker).
- **Build** : le premier build télécharge le moteur et les modèles d'export (environ 1 Go). Il faut prévoir quelques minutes et environ 2 Go de disque libre sur le VPS. Les builds suivants profitent du cache Docker tant que `GODOT_VERSION` ne change pas.

## Variables

| Nom | Quand | Rôle |
|---|---|---|
| `GODOT_VERSION` | build (argument Docker, facultatif) | version du moteur, 4.7.2 par défaut ; à garder alignée avec l'éditeur |

Aucun secret côté application. Les jetons d'outillage (`COOLIFY_BASE_URL`, `COOLIFY_ACCESS_TOKEN`, `CLOUDFLARE_API_TOKEN`) servent seulement à `kit api` et vivent dans l'environnement cloud ou dans `kit secrets`. Ils ne sont jamais dans le dépôt.

## Données

- **Volume persistant** : aucun. Le jeu est 100 % statique et la sauvegarde v1 est hors périmètre (une sauvegarde future irait dans le stockage du navigateur, pas sur le serveur).
- **Assets** : uniquement des packs gratuits sous licence CC0 (Kenney, Ninja Adventure, piano_no_renshu, m5x7). Ils peuvent être versionnés et diffusés sans restriction.

## Domaine

- **FQDN** : `occ.fs0ciety.org`. Nom libre (vérifié le 2026-11-05 : aucun enregistrement), mais le joker `*.fs0ciety.org` pointe déjà vers `152.53.176.13`.
- **Zone Cloudflare** : `fs0ciety.org` (id `7c749c5d4c715e429122addb7f3829d7`).
- **Enregistrement DNS à créer** : type `A`, nom `occ`, cible `152.53.176.13` (le VPS Coolify, à confirmer avec `kit api coolify /servers`), **proxifié**.
- **SSL/TLS** : Full (strict), déjà actif sur la zone. Coolify (Traefik) émet le certificat Let's Encrypt à l'origine. Jamais « Flexible ».
- **Accès** : public, URL non listée. On peut ajouter Cloudflare Access plus tard sans changer l'application.

## Mise en production

1. Tests, lint et build passent : `gdlint`, les tests sans interface et l'export web en local ou en CI.
2. Variables attendues présentes : aucune côté application. `COOLIFY_BASE_URL` et `COOLIFY_ACCESS_TOKEN` doivent être disponibles pour `kit api`.
3. Application Coolify créée :
   - mode Dockerfile, branche `main`, port exposé `80` ;
   - santé sur `/health` ;
   - domaine `https://occ.fs0ciety.org`.
4. Enregistrement DNS créé, domaine ajouté dans Coolify, certificat émis.
5. Vérification :
   - statut `running:healthy` ;
   - `https://occ.fs0ciety.org/health` renvoie 200 ;
   - `https://occ.fs0ciety.org/` charge le jeu ;
   - temps de chargement inférieur à 5 s (critère du brief) ;
   - logs récents sans erreur.

## Retour arrière

- **Application** : dans Coolify, redéployer le déploiement précédent, ou faire `git revert` du commit fautif sur `main` puis redéployer. Comme il n'y a ni base ni volume, aucune donnée n'est à restaurer.
- **DNS** : passer l'enregistrement `occ` en « DNS seul » si le certificat ne s'émet pas derrière le proxy, le temps de l'émission. Ne jamais passer en mode SSL « Flexible ».
- **Sauvegarde** : le dépôt Git suffit (image reconstruisible).
