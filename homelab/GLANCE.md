# Glance Dashboard

Learning cockpit at `http://homepage.lan` (CT 102, NPM proxy).

## Layout

| Column | Contents |
|--------|----------|
| Start Here | Clock, calendar, study todo, SearXNG search |
| Study | Service monitor, course book, online docs (Arrow, Parquet, DataFusion, Rust, databases) |
| Reference | Server stats, DevDocs, GitHub repos, infra links |

## Deploy

```bash
scp ~/dotfiles/homelab/glance/glance.yml root@proxmox:/tmp/glance.yml
ssh root@proxmox 'pct push 102 /tmp/glance.yml /root/glance/config/glance.yml'
```

## Retired

- Homepage (gethomepage.dev) — archived in `homepage/`
- BookStack (CT 106)
- Kiwix (CT 107) — online docs + course mdBook on `:8089` instead

## Course book

`homelab/course-book/` — mdBook from `bookstack-content/course/`. Deploy:

```bash
~/dotfiles/homelab/course-book/build-and-deploy.sh
```

Live at http://192.168.1.175:8089
