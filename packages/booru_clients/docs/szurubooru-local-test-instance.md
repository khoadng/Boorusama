# Local Szurubooru Test Instance

This runbook describes a disposable local Szurubooru instance for testing the
Boorusama Szurubooru client. It covers setup, API token creation, seed data,
pools, favorites, votes, and verification commands.

The commands are intentionally parameterized so another machine can reuse them
without relying on one exact port, password, or seed size.

## Parameters

Run these from the repository root:

```sh
export SZURUBOORU_WORK_DIR="${SZURUBOORU_WORK_DIR:-$PWD/.tmp/szurubooru-local}"
export SZURUBOORU_COMPOSE_PROJECT="${SZURUBOORU_COMPOSE_PROJECT:-boorusama-szuru-test}"
export SZURUBOORU_PORT="${SZURUBOORU_PORT:-18080}"
export SZURUBOORU_URL="${SZURUBOORU_URL:-http://127.0.0.1:$SZURUBOORU_PORT}"
export SZURUBOORU_API_URL="${SZURUBOORU_API_URL:-$SZURUBOORU_URL/api}"

export SZURUBOORU_POSTGRES_USER="${SZURUBOORU_POSTGRES_USER:-szuru}"
export SZURUBOORU_POSTGRES_PASSWORD="${SZURUBOORU_POSTGRES_PASSWORD:-szuru-local-test}"

export SZURUBOORU_ADMIN_USER="${SZURUBOORU_ADMIN_USER:-boorusama_admin}"
export SZURUBOORU_ADMIN_PASSWORD="${SZURUBOORU_ADMIN_PASSWORD:-boorusama_admin_password}"

export SZURUBOORU_SEED_COUNT="${SZURUBOORU_SEED_COUNT:-120}"
export SZURUBOORU_POOL_SIZE="${SZURUBOORU_POOL_SIZE:-20}"
export SZURUBOORU_FAVORITE_EVERY="${SZURUBOORU_FAVORITE_EVERY:-10}"
export SZURUBOORU_VERIFY_LIMIT="${SZURUBOORU_VERIFY_LIMIT:-21}"
export SZURUBOORU_SEED_TAG="${SZURUBOORU_SEED_TAG:-seed_szurubooru_client_test}"
export SZURUBOORU_SEED_SERIES_TAG="${SZURUBOORU_SEED_SERIES_TAG:-series_pagination_test}"
export SZURUBOORU_SEED_BATCH_TAG="${SZURUBOORU_SEED_BATCH_TAG:-batch_local_seed}"
```

## Start Szurubooru

Create a minimal disposable compose project:

```sh
mkdir -p "$SZURUBOORU_WORK_DIR"/{data,sql,server}

cat > "$SZURUBOORU_WORK_DIR/server/config.yaml" <<YAML
name: boorusama szurubooru local test
domain: $SZURUBOORU_URL
secret: boorusama-local-szurubooru-test-secret
data_dir: /data
delete_source_files: yes

enable_safety: yes
tag_name_regex: ^\S+$
tag_category_name_regex: ^[^\s%+#/]+$
pool_name_regex: ^\S+$
pool_category_name_regex: ^[^\s%+#/]+$
password_regex: '^.{5,}$'
user_name_regex: '^[a-zA-Z0-9_-]{1,32}$'
default_rank: regular

smtp:
  host:
  port:
  user:
  pass:
  from:
contact_email:

thumbnails:
  avatar_width: 300
  avatar_height: 300
  post_width: 300
  post_height: 300

convert:
  gif:
    to_webm: false
    to_mp4: false

allow_broken_uploads: false
max_dl_filesize: 25.0E+6
user_agent:
webhooks: []

privileges:
  'users:create:self': anonymous
  'users:create:any': administrator
  'users:list': regular
  'users:view': regular
  'users:edit:any:name': moderator
  'users:edit:any:pass': moderator
  'users:edit:any:email': moderator
  'users:edit:any:avatar': moderator
  'users:edit:any:rank': moderator
  'users:edit:self:name': regular
  'users:edit:self:pass': regular
  'users:edit:self:email': regular
  'users:edit:self:avatar': regular
  'users:edit:self:rank': moderator
  'users:delete:any': administrator
  'users:delete:self': regular

  'user_tokens:list:any': administrator
  'user_tokens:list:self': regular
  'user_tokens:create:any': administrator
  'user_tokens:create:self': regular
  'user_tokens:edit:any': administrator
  'user_tokens:edit:self': regular
  'user_tokens:delete:any': administrator
  'user_tokens:delete:self': regular

  'posts:create:anonymous': regular
  'posts:create:identified': regular
  'posts:list': anonymous
  'posts:reverse_search': regular
  'posts:view': anonymous
  'posts:view:featured': anonymous
  'posts:edit:content': power
  'posts:edit:flags': regular
  'posts:edit:notes': regular
  'posts:edit:relations': regular
  'posts:edit:safety': power
  'posts:edit:source': regular
  'posts:edit:tags': regular
  'posts:edit:thumbnail': power
  'posts:feature': moderator
  'posts:delete': moderator
  'posts:score': regular
  'posts:merge': moderator
  'posts:favorite': regular
  'posts:bulk-edit:tags': power
  'posts:bulk-edit:safety': power
  'posts:bulk-edit:delete': power

  'tags:create': regular
  'tags:edit:names': power
  'tags:edit:category': power
  'tags:edit:description': power
  'tags:edit:implications': power
  'tags:edit:suggestions': power
  'tags:list': regular
  'tags:view': anonymous
  'tags:merge': moderator
  'tags:delete': moderator

  'tag_categories:create': moderator
  'tag_categories:edit:name': moderator
  'tag_categories:edit:color': moderator
  'tag_categories:edit:order': moderator
  'tag_categories:list': anonymous
  'tag_categories:view': anonymous
  'tag_categories:delete': moderator
  'tag_categories:set_default': moderator

  'pools:create': regular
  'pools:edit:names': power
  'pools:edit:category': power
  'pools:edit:description': power
  'pools:edit:posts': power
  'pools:list': regular
  'pools:view': anonymous
  'pools:merge': moderator
  'pools:delete': moderator

  'pool_categories:create': moderator
  'pool_categories:edit:name': moderator
  'pool_categories:edit:color': moderator
  'pool_categories:list': anonymous
  'pool_categories:view': anonymous
  'pool_categories:delete': moderator
  'pool_categories:set_default': moderator

  'comments:create': regular
  'comments:delete:any': moderator
  'comments:delete:own': regular
  'comments:edit:any': moderator
  'comments:edit:own': regular
  'comments:list': anonymous
  'comments:view': anonymous
  'comments:score': regular

  'snapshots:list': power
  'uploads:create': regular
  'uploads:use_downloader': power
YAML

cat > "$SZURUBOORU_WORK_DIR/docker-compose.yml" <<YAML
services:
  server:
    image: szurubooru/server:latest
    depends_on:
      - sql
    environment:
      POSTGRES_HOST: sql
      POSTGRES_USER: "$SZURUBOORU_POSTGRES_USER"
      POSTGRES_PASSWORD: "$SZURUBOORU_POSTGRES_PASSWORD"
      THREADS: 4
    volumes:
      - "./data:/data"
      - "./server/config.yaml:/opt/app/config.yaml:ro"

  client:
    image: szurubooru/client:latest
    depends_on:
      - server
    environment:
      BACKEND_HOST: server
      BASE_URL: /
    volumes:
      - "./data:/data:ro"
    ports:
      - "$SZURUBOORU_PORT:80"

  sql:
    image: postgres:11-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: "$SZURUBOORU_POSTGRES_USER"
      POSTGRES_PASSWORD: "$SZURUBOORU_POSTGRES_PASSWORD"
    volumes:
      - "./sql:/var/lib/postgresql/data"
YAML

docker compose \
  --project-directory "$SZURUBOORU_WORK_DIR" \
  -p "$SZURUBOORU_COMPOSE_PROJECT" \
  up -d
```

Wait for the API:

```sh
until curl -fsS -H 'Accept: application/json' "$SZURUBOORU_API_URL/info" >/dev/null; do
  sleep 2
done
```

For Boorusama, use:

```text
URL: http://127.0.0.1:18080
Username: boorusama_admin
API key: <token created below>
```

## Create Admin And API Token

The first user created on a fresh Szurubooru database becomes administrator.

```sh
curl -fsS -X POST \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  --data "$(ruby -rjson -e 'puts JSON.generate({name: ENV.fetch("SZURUBOORU_ADMIN_USER"), password: ENV.fetch("SZURUBOORU_ADMIN_PASSWORD")})')" \
  "$SZURUBOORU_API_URL/users" >/dev/null
```

Create a user token for the app:

```sh
basic_auth="$(
  printf '%s:%s' "$SZURUBOORU_ADMIN_USER" "$SZURUBOORU_ADMIN_PASSWORD" |
    base64 | tr -d '\n'
)"

token_json="$(
  curl -fsS -X POST \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H "Authorization: Basic $basic_auth" \
    --data '{"enabled":true,"note":"Boorusama local test"}' \
    "$SZURUBOORU_API_URL/user-token/$SZURUBOORU_ADMIN_USER"
)"

export SZURUBOORU_API_TOKEN="$(
  printf '%s' "$token_json" |
    ruby -rjson -e 'puts JSON.parse(STDIN.read).fetch("token")'
)"

export SZURUBOORU_TOKEN_AUTH="$(
  printf '%s:%s' "$SZURUBOORU_ADMIN_USER" "$SZURUBOORU_API_TOKEN" |
    base64 | tr -d '\n'
)"
```

Verify:

```sh
curl -fsS \
  -H 'Accept: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  "$SZURUBOORU_API_URL/user/$SZURUBOORU_ADMIN_USER"
```

## Seed Categories

Create one default tag category and two pool categories:

```sh
curl -fsS -X POST \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data '{"name":"general","color":"#aaaaaa","order":0}' \
  "$SZURUBOORU_API_URL/tag-categories" >/dev/null

curl -fsS -X POST \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data '{"name":"series","color":"#a0b7ff"}' \
  "$SZURUBOORU_API_URL/pool-categories" >/dev/null

curl -fsS -X POST \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data '{"name":"collection","color":"#a7d7a7"}' \
  "$SZURUBOORU_API_URL/pool-categories" >/dev/null
```

## Seed Test Data

The seed script generates unique PNG files locally, uploads them, applies
predictable tags, marks every Nth post as favorite, votes on posts, and creates
ordered pools.

```sh
mkdir -p "$SZURUBOORU_WORK_DIR/seed"

python3 - <<'PY'
import os
import struct
import zlib

seed_dir = os.path.join(os.environ["SZURUBOORU_WORK_DIR"], "seed")
count = int(os.environ.get("SZURUBOORU_SEED_COUNT", "120"))
os.makedirs(seed_dir, exist_ok=True)

def chunk(kind, data):
    return (
        struct.pack(">I", len(data)) +
        kind +
        data +
        struct.pack(">I", zlib.crc32(kind + data) & 0xffffffff)
    )

def write_png(path, width, height, i):
    rows = []
    for y in range(height):
        row = bytearray([0])
        for x in range(width):
            row.extend((
                (x + i * 53) % 256,
                (y + i * 97) % 256,
                ((x // 8) + (y // 8) + i * 31) % 256,
            ))
        rows.append(bytes(row))
    raw = b"".join(rows)
    png = (
        b"\x89PNG\r\n\x1a\n" +
        chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)) +
        chunk(b"IDAT", zlib.compress(raw, 9)) +
        chunk(b"IEND", b"")
    )
    with open(path, "wb") as fh:
        fh.write(png)

for i in range(1, count + 1):
    write_png(os.path.join(seed_dir, f"seed_{i:03d}.png"), 320, 220, i)
PY

post_ids_file="$SZURUBOORU_WORK_DIR/seed/post_ids.txt"
: > "$post_ids_file"

for i in $(seq 1 "$SZURUBOORU_SEED_COUNT"); do
  idx="$(printf '%03d' "$i")"
  group="$(printf '%02d' $(( (i - 1) / SZURUBOORU_POOL_SIZE )))"
  artist="$(printf '%02d' $(( (i - 1) % 12 )))"
  character="$(printf '%02d' $(( (i - 1) % 24 )))"
  color="$(( i % 6 ))"
  if [ $((i % 2)) -eq 0 ]; then parity="even"; else parity="odd"; fi
  case $((i % 3)) in
    0) safety="unsafe" ;;
    1) safety="safe" ;;
    *) safety="sketchy" ;;
  esac

  metadata="$(
    IDX="$idx" \
    GROUP="$group" \
    ARTIST="$artist" \
    CHARACTER="$character" \
    COLOR="$color" \
    PARITY="$parity" \
    SAFETY="$safety" \
    ruby -rjson -e '
      tags = [
        ENV.fetch("SZURUBOORU_SEED_TAG"),
        ENV.fetch("SZURUBOORU_SEED_SERIES_TAG"),
        ENV.fetch("SZURUBOORU_SEED_BATCH_TAG"),
        "page_group_#{ENV.fetch("GROUP")}",
        "artist_seed_artist_#{ENV.fetch("ARTIST")}",
        "character_seed_character_#{ENV.fetch("CHARACTER")}",
        "color_seed_color_#{ENV.fetch("COLOR")}",
        "parity_#{ENV.fetch("PARITY")}",
        "seed_index_#{ENV.fetch("IDX")}",
      ]
      puts JSON.generate({
        tags: tags,
        safety: ENV.fetch("SAFETY"),
        source: "local-szurubooru-seed/#{ENV.fetch("IDX")}",
      })
    '
  )"

  resp="$(
    curl -fsS -X POST \
      -H 'Accept: application/json' \
      -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
      -F "metadata=$metadata;type=application/json" \
      -F "content=@$SZURUBOORU_WORK_DIR/seed/seed_${idx}.png;type=image/png" \
      "$SZURUBOORU_API_URL/posts"
  )"

  post_id="$(printf '%s' "$resp" | ruby -rjson -e 'puts JSON.parse(STDIN.read).fetch("id")')"
  printf '%s\n' "$post_id" >> "$post_ids_file"

  score=1
  if [ $((i % 5)) -eq 0 ]; then score=-1; fi
  curl -fsS -X PUT \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
    --data "{\"score\":$score}" \
    "$SZURUBOORU_API_URL/post/$post_id/score" >/dev/null

  if [ "$SZURUBOORU_FAVORITE_EVERY" -gt 0 ] && [ $((i % SZURUBOORU_FAVORITE_EVERY)) -eq 0 ]; then
    curl -fsS -X POST \
      -H 'Accept: application/json' \
      -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
      "$SZURUBOORU_API_URL/post/$post_id/favorite" >/dev/null
  fi

  if [ $((i % 40)) -eq 0 ]; then
    echo "Seeded $i / $SZURUBOORU_SEED_COUNT posts"
  fi
done

pool_count=$(( (SZURUBOORU_SEED_COUNT + SZURUBOORU_POOL_SIZE - 1) / SZURUBOORU_POOL_SIZE ))
for pool_index in $(seq 0 $((pool_count - 1))); do
  start=$((pool_index * SZURUBOORU_POOL_SIZE + 1))
  end=$((start + SZURUBOORU_POOL_SIZE - 1))
  ids="$(
    sed -n "${start},${end}p" "$post_ids_file" |
      paste -sd ',' -
  )"
  [ -n "$ids" ] || continue

  pool_idx="$(printf '%02d' "$pool_index")"
  metadata="$(
    IDS="$ids" POOL_IDX="$pool_idx" ruby -rjson -e '
      posts = ENV.fetch("IDS").split(",").map(&:to_i)
      puts JSON.generate({
        names: ["seed_pool_#{ENV.fetch("POOL_IDX")}"],
        category: "series",
        description: "Local test pool #{ENV.fetch("POOL_IDX")} seeded for Boorusama.",
        posts: posts,
      })
    '
  )"

  curl -fsS -X POST \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
    --data "$metadata" \
    "$SZURUBOORU_API_URL/pool" >/dev/null
done

printf 'Seeded posts=%s pools=%s\n' "$SZURUBOORU_SEED_COUNT" "$pool_count"
```

The generated files remain on the host:

```text
.tmp/szurubooru-local/seed
```

## Seeded Tags

The seed creates:

```text
$SZURUBOORU_SEED_TAG
$SZURUBOORU_SEED_SERIES_TAG
$SZURUBOORU_SEED_BATCH_TAG
page_group_00 ...
artist_seed_artist_00 ... artist_seed_artist_11
character_seed_character_00 ... character_seed_character_23
color_seed_color_0 ... color_seed_color_5
parity_even
parity_odd
seed_index_001 ...
```

Useful app searches:

```text
seed_szurubooru_client_test
page_group_00
artist_seed_artist_00
parity_even
special:fav seed_szurubooru_client_test
pool:1
```

Useful pool searches:

```text
*seed_pool_*
sort:post-count
category:series
```

## Verify Seed Data

Total seeded posts:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  --data-urlencode "query=$SZURUBOORU_SEED_TAG" \
  --data-urlencode "limit=1" \
  "$SZURUBOORU_API_URL/posts" |
  ruby -rjson -e 'expected = Integer(ENV.fetch("SZURUBOORU_SEED_COUNT")); actual = JSON.parse(STDIN.read).fetch("total"); abort "expected #{expected}, got #{actual}" unless actual == expected; puts actual'
```

Bounded search:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  --data-urlencode "query=$SZURUBOORU_SEED_TAG" \
  --data-urlencode "limit=$SZURUBOORU_VERIFY_LIMIT" \
  "$SZURUBOORU_API_URL/posts" |
  ruby -rjson -e 'expected = Integer(ENV.fetch("SZURUBOORU_VERIFY_LIMIT")); actual = JSON.parse(STDIN.read).fetch("results").length; abort "expected #{expected}, got #{actual}" unless actual == expected; puts actual'
```

Single group:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  --data-urlencode 'query=page_group_00' \
  --data-urlencode "limit=$SZURUBOORU_POOL_SIZE" \
  "$SZURUBOORU_API_URL/posts" |
  ruby -rjson -e 'expected = Integer(ENV.fetch("SZURUBOORU_POOL_SIZE")); actual = JSON.parse(STDIN.read).fetch("total"); abort "expected #{expected}, got #{actual}" unless actual == expected; puts actual'
```

Favorites:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data-urlencode "query=special:fav $SZURUBOORU_SEED_TAG" \
  --data-urlencode "limit=1" \
  "$SZURUBOORU_API_URL/posts" |
  ruby -rjson -e 'count = Integer(ENV.fetch("SZURUBOORU_SEED_COUNT")); every = Integer(ENV.fetch("SZURUBOORU_FAVORITE_EVERY")); expected = every > 0 ? count / every : 0; actual = JSON.parse(STDIN.read).fetch("total"); abort "expected #{expected}, got #{actual}" unless actual == expected; puts actual'
```

Pools:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data-urlencode 'query=*seed_pool_* sort:name' \
  --data-urlencode 'limit=50' \
  "$SZURUBOORU_API_URL/pools" |
  ruby -rjson -e 'expected = (Integer(ENV.fetch("SZURUBOORU_SEED_COUNT")) + Integer(ENV.fetch("SZURUBOORU_POOL_SIZE")) - 1) / Integer(ENV.fetch("SZURUBOORU_POOL_SIZE")); actual = JSON.parse(STDIN.read).fetch("total"); abort "expected #{expected}, got #{actual}" unless actual == expected; puts actual'
```

Autocomplete:

```sh
curl -fsS -G \
  -H 'Accept: application/json' \
  -H "Authorization: Token $SZURUBOORU_TOKEN_AUTH" \
  --data-urlencode 'query=artist_seed_artist_* sort:usages' \
  --data-urlencode 'limit=12' \
  "$SZURUBOORU_API_URL/tags"
```

Expected: seed artist tags with non-zero usages.

## Cleanup

Stop the containers:

```sh
docker compose \
  --project-directory "$SZURUBOORU_WORK_DIR" \
  -p "$SZURUBOORU_COMPOSE_PROJECT" \
  stop
```

Start them again later:

```sh
docker compose \
  --project-directory "$SZURUBOORU_WORK_DIR" \
  -p "$SZURUBOORU_COMPOSE_PROJECT" \
  start
```

Delete containers while keeping database and data files:

```sh
docker compose \
  --project-directory "$SZURUBOORU_WORK_DIR" \
  -p "$SZURUBOORU_COMPOSE_PROJECT" \
  down
```

Delete all local Szurubooru test data:

```sh
docker compose \
  --project-directory "$SZURUBOORU_WORK_DIR" \
  -p "$SZURUBOORU_COMPOSE_PROJECT" \
  down -v
rm -rf "$SZURUBOORU_WORK_DIR"
```
