#!/usr/bin/env bash
#
# convert-to-mp3.sh
# Converts every .ogg file in the current folder to .mp3 (same name).
# Originals are kept; .mp3 files are created next to them.
#
# USAGE:
#   1. Put this file inside your "audio/" folder (next to the .ogg files).
#   2. Open a terminal in that folder.
#   3. Run:   bash convert-to-mp3.sh
#      (optional quality:  bash convert-to-mp3.sh 4   -> smaller files)
#
# REQUIREMENTS: ffmpeg must be installed.
#   macOS:    brew install ffmpeg
#   Ubuntu:   sudo apt install ffmpeg
#   Windows:  install via https://www.gyan.dev/ffmpeg/builds/ , or use WSL/Git Bash
#
# QUALITY: the number is ffmpeg's VBR setting (-q:a).
#   0 = best quality / biggest files
#   2 = ~190 kbps  (default, great for songs)
#   4 = ~165 kbps
#   6 = ~130 kbps  (fine for spoken discourses, smaller)

set -euo pipefail
shopt -s nullglob nocaseglob   # match .OGG too; no error if none found

QUALITY="${1:-2}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ERROR: ffmpeg is not installed. See the notes at the top of this script."
  exit 1
fi

found=0; converted=0; skipped=0

for f in *.ogg; do
  found=$((found+1))
  out="${f%.*}.mp3"
  if [[ -f "$out" ]]; then
    echo "skip (already exists): $out"
    skipped=$((skipped+1))
    continue
  fi
  echo "converting: $f"
  ffmpeg -hide_banner -loglevel error -y \
    -i "$f" \
    -codec:a libmp3lame -q:a "$QUALITY" \
    -map_metadata 0 -id3v2_version 3 \
    "$out"
  converted=$((converted+1))
done

echo "--------------------------------------------"
if [[ $found -eq 0 ]]; then
  echo "No .ogg files found in this folder."
else
  echo "Found $found  |  converted $converted  |  skipped $skipped"
  echo "Done. Upload the new .mp3 files, then set AUDIO_EXT = \".mp3\" in index.html."
fi
