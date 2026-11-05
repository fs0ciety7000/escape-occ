# Build the Godot web export, then serve it with nginx.
ARG GODOT_VERSION=4.7.2

FROM debian:bookworm-slim AS build
ARG GODOT_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl unzip libfontconfig1 \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/godot
RUN base="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable" \
 && curl -fsSL -o godot.zip "$base/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
 && unzip -q godot.zip && mv "Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot \
 && curl -fsSL -o templates.tpz "$base/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" \
 && mkdir -p "/root/.local/share/godot/export_templates/${GODOT_VERSION}.stable" \
 && unzip -q -j templates.tpz "templates/web_*" -d "/root/.local/share/godot/export_templates/${GODOT_VERSION}.stable" \
 && rm -f godot.zip templates.tpz
WORKDIR /src
COPY . .
RUN godot --headless --path . --import \
 && mkdir -p build/web \
 && godot --headless --path . --export-release "Web" build/web/index.html \
 && test -f build/web/index.html

FROM nginx:1.27-alpine
RUN apk add --no-cache openssl
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
# Runs at container start: writes /etc/nginx/.htpasswd from BASIC_AUTH_USER / BASIC_AUTH_PASSWORD.
COPY --chmod=755 deploy/40-basic-auth.sh /docker-entrypoint.d/40-basic-auth.sh
COPY --from=build /src/build/web /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1/health || exit 1
