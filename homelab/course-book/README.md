# Rust Database Developer Course (mdBook)

Curated course built from `../bookstack-content/course/`. Served on the homelab at **http://192.168.1.175:8089** (nginx on CT 104).

## Build locally

```bash
brew install mdbook   # once
cd ~/dotfiles/homelab/course-book
./build-and-deploy.sh
```

## Edit content

Change markdown in `homelab/bookstack-content/course/`, then re-run `./build-and-deploy.sh`.

## Local preview

```bash
./build-and-deploy.sh   # or manually:
cp -r ../bookstack-content/course/*.md src/chapters/  # see build script
mdbook serve            # http://localhost:3000
```
