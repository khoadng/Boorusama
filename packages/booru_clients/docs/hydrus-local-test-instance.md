# Local Hydrus Test Instance

This runbook describes a disposable local Hydrus instance for testing the
Boorusama Hydrus client. It covers setup, API key creation, seed data, and
verification commands.

The commands are intentionally parameterized so another can reuse them
without relying on one machine, one access key, or one exact seed size.

## Parameters

Run these from the repository root:

```sh
export HYDRUS_CONTAINER_NAME="${HYDRUS_CONTAINER_NAME:-hydrus-client-test}"
export HYDRUS_DATA_DIR="${HYDRUS_DATA_DIR:-$PWD/.tmp/hydrus-data}"
export HYDRUS_API_URL="${HYDRUS_API_URL:-http://127.0.0.1:45869}"
export HYDRUS_UI_URL="${HYDRUS_UI_URL:-http://127.0.0.1:5800/vnc.html}"

export HYDRUS_SEED_COUNT="${HYDRUS_SEED_COUNT:-240}"
export HYDRUS_GROUP_SIZE="${HYDRUS_GROUP_SIZE:-20}"
export HYDRUS_FAVORITE_EVERY="${HYDRUS_FAVORITE_EVERY:-10}"
export HYDRUS_VERIFY_LIMIT="${HYDRUS_VERIFY_LIMIT:-21}"
export HYDRUS_SEED_TAG="${HYDRUS_SEED_TAG:-seed:hydrus_client_test}"
export HYDRUS_SEED_SERIES_TAG="${HYDRUS_SEED_SERIES_TAG:-series:pagination_test}"
export HYDRUS_SEED_BATCH_TAG="${HYDRUS_SEED_BATCH_TAG:-batch:local_seed}"
```

## Start Hydrus

```sh
mkdir -p "$HYDRUS_DATA_DIR"

docker run -d --name "$HYDRUS_CONTAINER_NAME" \
  -p 5800:5800 \
  -p 5900:5900 \
  -p 45869:45869 \
  -v "$HYDRUS_DATA_DIR:/opt/hydrus/db" \
  ghcr.io/hydrusnetwork/hydrus:latest
```

Install tools used by the seed flow:

```sh
docker exec "$HYDRUS_CONTAINER_NAME" sh -lc \
  'apk add --no-cache curl imagemagick'
```

The Hydrus UI is available at:

```sh
printf '%s\n' "$HYDRUS_UI_URL"
```

## Enable The Client API

On a fresh Hydrus profile, the Client API is disabled. Open the noVNC UI and
enable it:

1. `services -> manage services...`
2. Select `client api`
3. Click `edit`
4. Enable `run the client api?`
5. Enable `allow non-local connections`
6. Enable `support CORS headers`
7. Apply the dialogs.

Verify:

```sh
curl -sS "$HYDRUS_API_URL/api_version"
```

Expected shape:

```json
{"version":90,"hydrus_version":670}
```

The numbers vary by Hydrus version.

## Create An API Key

Open the Hydrus UI:

1. `services -> review services`
2. Select the `client api` tab
3. Click `add -> from api request`
4. Leave the dialog waiting for a request.

In another shell:

```sh
curl -sS \
  "$HYDRUS_API_URL/request_new_permissions?name=Hydrus%20Client%20Test&permits_everything=true"
```

Accept the request in the Hydrus UI. Save the returned access key:

```sh
export HYDRUS_API_KEY="<access_key_from_request_new_permissions>"
```

Verify:

```sh
curl -sS \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  "$HYDRUS_API_URL/verify_access_key"
```

For Boorusama, use:

```text
URL: http://127.0.0.1:45869
API key: <access_key_from_request_new_permissions>
```

## Resolve Service Keys

The seed script needs one local tag service and one like/dislike rating service.
This discovers them from Hydrus instead of hard-coding default keys:

```sh
services_json=$(curl -sS \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  "$HYDRUS_API_URL/get_services")

export HYDRUS_TAG_SERVICE_KEY="$(
  printf '%s' "$services_json" |
    ruby -rjson -e '
      data = JSON.parse(STDIN.read)
      services = data["services_v2"] || data.fetch("services", {}).map { |key, value| value.merge("service_key" => key) }
      service = services.find { |s| s["type"] == 5 }
      abort "No local tag service found" unless service
      puts service["service_key"]
    '
)"

export HYDRUS_FAVORITE_SERVICE_KEY="$(
  printf '%s' "$services_json" |
    ruby -rjson -e '
      data = JSON.parse(STDIN.read)
      services = data["services_v2"] || data.fetch("services", {}).map { |key, value| value.merge("service_key" => key) }
      service = services.find { |s| s["type"] == 7 }
      abort "No like/dislike rating service found" unless service
      puts service["service_key"]
    '
)"

export HYDRUS_FAVORITE_SERVICE_NAME="$(
  printf '%s' "$services_json" |
    ruby -rjson -e '
      data = JSON.parse(STDIN.read)
      services = data["services_v2"] || data.fetch("services", {}).map { |key, value| value.merge("service_key" => key) }
      service = services.find { |s| s["service_key"] == ENV.fetch("HYDRUS_FAVORITE_SERVICE_KEY") }
      abort "No matching favorite service found" unless service
      puts service["name"]
    '
)"
```

## Seed Test Data

The seed script generates unique PNG files in the container, imports them,
applies predictable tags, and marks every Nth file as liked.

```sh
docker exec \
  -e HYDRUS_API_KEY \
  -e HYDRUS_TAG_SERVICE_KEY \
  -e HYDRUS_FAVORITE_SERVICE_KEY \
  -e HYDRUS_SEED_COUNT \
  -e HYDRUS_GROUP_SIZE \
  -e HYDRUS_FAVORITE_EVERY \
  -e HYDRUS_VERIFY_LIMIT \
  -e HYDRUS_SEED_TAG \
  -e HYDRUS_SEED_SERIES_TAG \
  -e HYDRUS_SEED_BATCH_TAG \
  "$HYDRUS_CONTAINER_NAME" \
  sh -lc '
set -eu

API="http://127.0.0.1:45869"
SEED_DIR="/tmp/hydrus-client-seed"
mkdir -p "$SEED_DIR"

count="${HYDRUS_SEED_COUNT:-240}"
group_size="${HYDRUS_GROUP_SIZE:-20}"
favorite_every="${HYDRUS_FAVORITE_EVERY:-10}"

imported=0
tagged=0
liked=0

for i in $(seq 1 "$count"); do
  idx=$(printf "%03d" "$i")
  img="$SEED_DIR/seed_${idx}.png"

  r=$(( (i * 53) % 256 ))
  g=$(( (i * 97) % 256 ))
  b=$(( (i * 193) % 256 ))
  color=$(printf "#%02x%02x%02x" "$r" "$g" "$b")

  convert -size 320x220 "xc:$color" \
    -gravity center \
    -pointsize 24 \
    -fill white \
    -annotate 0 "Hydrus Seed\n#$idx" \
    "$img" >/dev/null 2>&1

  body=$(printf "{\"path\":\"%s\"}" "$img")
  resp=$(curl -sS -X POST \
    -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
    -H "Content-Type: application/json" \
    --data "$body" \
    "$API/add_files/add_file")

  hash=$(printf "%s" "$resp" | sed -n "s/.*\"hash\": \"\([^\"]*\)\".*/\1/p")
  if [ -z "$hash" ]; then
    echo "Failed import $img: $resp" >&2
    exit 1
  fi
  imported=$((imported + 1))

  group=$(printf "%02d" $(( (i - 1) / group_size )))
  artist=$(( (i - 1) % 12 ))
  character=$(( (i - 1) % 24 ))
  color_tag=$(( i % 6 ))
  if [ $((i % 2)) -eq 0 ]; then parity="even"; else parity="odd"; fi

  tags=$(printf "[\"%s\",\"%s\",\"%s\",\"page_group:%s\",\"artist:seed_artist_%02d\",\"character:seed_character_%02d\",\"color:seed_color_%d\",\"parity:%s\",\"seed:index_%s\"]" \
    "$HYDRUS_SEED_TAG" \
    "$HYDRUS_SEED_SERIES_TAG" \
    "$HYDRUS_SEED_BATCH_TAG" \
    "$group" \
    "$artist" \
    "$character" \
    "$color_tag" \
    "$parity" \
    "$idx")

  tag_body=$(printf "{\"hash\":\"%s\",\"service_keys_to_tags\":{\"%s\":%s}}" \
    "$hash" \
    "$HYDRUS_TAG_SERVICE_KEY" \
    "$tags")

  curl -sS -X POST \
    -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
    -H "Content-Type: application/json" \
    --data "$tag_body" \
    "$API/add_tags/add_tags" >/dev/null
  tagged=$((tagged + 1))

  if [ "$favorite_every" -gt 0 ] && [ $((i % favorite_every)) -eq 0 ]; then
    rating_body=$(printf "{\"hash\":\"%s\",\"rating_service_key\":\"%s\",\"rating\":true}" \
      "$hash" \
      "$HYDRUS_FAVORITE_SERVICE_KEY")

    curl -sS -X POST \
      -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
      -H "Content-Type: application/json" \
      --data "$rating_body" \
      "$API/edit_ratings/set_rating" >/dev/null
    liked=$((liked + 1))
  fi

  if [ $((i % 40)) -eq 0 ]; then
    echo "Seeded $i / $count"
  fi
done

printf "Imported=%s Tagged=%s Liked=%s\n" "$imported" "$tagged" "$liked"
'
```

The generated files remain inside the container:

```text
/tmp/hydrus-client-seed
```

## Seeded Tags

The seed creates:

```text
$HYDRUS_SEED_TAG
$HYDRUS_SEED_SERIES_TAG
$HYDRUS_SEED_BATCH_TAG
page_group:00 ...
artist:seed_artist_00 ... artist:seed_artist_11
character:seed_character_00 ... character:seed_character_23
color:seed_color_0 ... color:seed_color_5
parity:even
parity:odd
seed:index_001 ...
```

Useful app searches:

```text
seed:hydrus_client_test
page_group:00
artist:seed_artist_00
parity:even
system:rating for <favorite service name> = like
```

## Verify Seed Data

Total seeded files:

```sh
curl -sS -G \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  --data-urlencode "tags=[\"$HYDRUS_SEED_TAG\"]" \
  "$HYDRUS_API_URL/get_files/search_files" \
  | ruby -rjson -e "expected = Integer(ENV.fetch(\"HYDRUS_SEED_COUNT\")); actual = JSON.parse(STDIN.read)[\"file_ids\"].length; abort \"expected #{expected}, got #{actual}\" unless actual == expected; puts actual"
```

Bounded search:

```sh
curl -sS -G \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  --data-urlencode "tags=[\"$HYDRUS_SEED_TAG\",\"system:limit = $HYDRUS_VERIFY_LIMIT\"]" \
  "$HYDRUS_API_URL/get_files/search_files" \
  | ruby -rjson -e "expected = Integer(ENV.fetch(\"HYDRUS_VERIFY_LIMIT\")); actual = JSON.parse(STDIN.read)[\"file_ids\"].length; abort \"expected #{expected}, got #{actual}\" unless actual == expected; puts actual"
```

Single group:

```sh
curl -sS -G \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  --data-urlencode 'tags=["page_group:00"]' \
  "$HYDRUS_API_URL/get_files/search_files" \
  | ruby -rjson -e "expected = Integer(ENV.fetch(\"HYDRUS_GROUP_SIZE\")); actual = JSON.parse(STDIN.read)[\"file_ids\"].length; abort \"expected #{expected}, got #{actual}\" unless actual == expected; puts actual"
```

Liked/favorites:

```sh
curl -sS -G \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  --data-urlencode "tags=[\"system:rating for $HYDRUS_FAVORITE_SERVICE_NAME = like\",\"$HYDRUS_SEED_TAG\"]" \
  "$HYDRUS_API_URL/get_files/search_files" \
  | ruby -rjson -e "count = Integer(ENV.fetch(\"HYDRUS_SEED_COUNT\")); every = Integer(ENV.fetch(\"HYDRUS_FAVORITE_EVERY\")); expected = every > 0 ? count / every : 0; actual = JSON.parse(STDIN.read)[\"file_ids\"].length; abort \"expected #{expected}, got #{actual}\" unless actual == expected; puts actual"
```

Autocomplete:

```sh
curl -sS -G \
  -H "Hydrus-Client-API-Access-Key: $HYDRUS_API_KEY" \
  --data-urlencode 'search=seed_artist_' \
  --data-urlencode 'tag_display_type=display' \
  "$HYDRUS_API_URL/add_tags/search_tags"
```

Expected: seed artist tags with non-zero counts.

## Cleanup

Stop the container:

```sh
docker stop "$HYDRUS_CONTAINER_NAME"
```

Start it again later:

```sh
docker start "$HYDRUS_CONTAINER_NAME"
```

Delete the container while keeping the database:

```sh
docker rm -f "$HYDRUS_CONTAINER_NAME"
```

Delete all local Hydrus test data:

```sh
docker rm -f "$HYDRUS_CONTAINER_NAME"
rm -rf "$HYDRUS_DATA_DIR"
```
