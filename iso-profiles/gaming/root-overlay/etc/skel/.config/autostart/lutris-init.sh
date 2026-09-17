#!/usr/bin/env bash

cd ~/.config/autostart/

LUTRIS_CONF="${XDG_DATA_HOME:-$HOME/.config}/lutris"
LUTRIS_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/lutris"
GAMES="$LUTRIS_CONF/games"
BANNERS="$LUTRIS_DATA/banners"
COVERS="$LUTRIS_DATA/coverart"
ICONS="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/128x128/apps"
DB="$LUTRIS_DATA/pga.db"

mkdir -p "$GAMES" "$BANNERS" "$COVERS" "$ICONS"

lutris -l >/dev/null
[[ -f "$DB" ]] || {
    echo "ERROR: Lutris did not create $DB" >&2
    exit 1
}

add_game() {
    local name="$1" slug="$2" exe="$3"
    local config="$slug"
    local now=$(date +%s)

    cat > "$GAMES/${config}-$now.yml" <<EOF
game:
  exe: "$exe"
EOF

    sqlite3 "$DB" <<SQL
BEGIN;
INSERT INTO games(
    name, sortname, slug, platform, runner, directory,
    lastplayed, installed, installed_at, configpath,
    has_custom_banner, has_custom_icon, has_custom_coverart_big, playtime
) VALUES (
    '$name', '$slug', '$slug', 'Linux', 'linux', '',
    0, 1, '$now', '$config-$now',
    0, 0, 0, 0.0
);

SELECT last_insert_rowid();

COMMIT;
SQL
}

[ -x /usr/bin/beyondallreason ] && { add_game "Beyond All Reason" "beyond-all-reason" "/usr/bin/beyondallreason"; mkdir $HOME/.local/share/BeyondAllReason; }
[ -x /usr/bin/xonotic-glx ] && add_game "Xonotic (X11)" "xonotic" "/usr/bin/xonotic-glx"
[ -x /usr/bin/xonotic-sdl ] && add_game "Xonotic (Wayland)" "xonotic" "/usr/bin/xonotic-sdl"

for game in beyond-all-reason xonotic; do
    mv $game-banner.jpg "$BANNERS/$game.jpg"
    mv $game-icon.png "$ICONS/lutris_$game.png"
    mv $game-cover.jpg "$COVERS/$game.jpg"
done

rm -f lutris*
