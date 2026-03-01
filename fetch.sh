#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# fetch.sh — YouTube video data fetcher using yt-dlp and jq
# Usage: fetch.sh <mode> <url> [lang] [format]
# Modes: transcript | metadata | all
# =============================================================================

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------
if ! command -v yt-dlp &>/dev/null; then
  echo "Error: yt-dlp not installed. Run: brew install yt-dlp" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq not installed. Run: brew install jq" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
MODE="${1:-}"
URL="${2:-}"
LANG="${3:-en}"
FORMAT="${4:-json}"

if [[ -z "$MODE" || -z "$URL" ]]; then
  echo "Usage: fetch.sh <mode> <url> [lang] [format]" >&2
  echo "Modes: transcript | metadata | all" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Extract video ID for temp file naming
# ---------------------------------------------------------------------------
extract_video_id() {
  local url="$1"
  local vid=""

  # Store regexes in variables for Bash 3.2 compatibility (macOS)
  local re_watch='[?&]v=([a-zA-Z0-9_-]{11})'
  local re_short='youtu\.be/([a-zA-Z0-9_-]{11})'
  local re_shorts='youtube\.com/shorts/([a-zA-Z0-9_-]{11})'
  local re_embed='youtube\.com/embed/([a-zA-Z0-9_-]{11})'

  if [[ "$url" =~ $re_watch ]]; then
    vid="${BASH_REMATCH[1]}"
  elif [[ "$url" =~ $re_short ]]; then
    vid="${BASH_REMATCH[1]}"
  elif [[ "$url" =~ $re_shorts ]]; then
    vid="${BASH_REMATCH[1]}"
  elif [[ "$url" =~ $re_embed ]]; then
    vid="${BASH_REMATCH[1]}"
  else
    vid="unknown"
  fi

  echo "$vid"
}

VIDEO_ID="$(extract_video_id "$URL")"
TEMP_PREFIX="/tmp/media-extract-${VIDEO_ID}"

# ---------------------------------------------------------------------------
# Cleanup helper
# ---------------------------------------------------------------------------
cleanup_temp() {
  rm -f "${TEMP_PREFIX}"*.vtt "${TEMP_PREFIX}"*.json 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Format duration (seconds -> HH:MM:SS or MM:SS)
# ---------------------------------------------------------------------------
format_duration() {
  local total="$1"
  local h=$((total / 3600))
  local m=$(( (total % 3600) / 60 ))
  local s=$((total % 60))
  if [[ "$h" -gt 0 ]]; then
    printf "%02d:%02d:%02d" "$h" "$m" "$s"
  else
    printf "%02d:%02d" "$m" "$s"
  fi
}

# ---------------------------------------------------------------------------
# Format timestamp for transcript (seconds -> MM:SS)
# ---------------------------------------------------------------------------
format_timestamp() {
  local total="$1"
  local m=$((total / 60))
  local s=$((total % 60))
  printf "%02d:%02d" "$m" "$s"
}

# ---------------------------------------------------------------------------
# Decode HTML entities
# ---------------------------------------------------------------------------
decode_html_entities() {
  sed -e 's/&amp;/\&/g' \
      -e "s/&#39;/'/g" \
      -e 's/&quot;/"/g' \
      -e 's/&lt;/</g' \
      -e 's/&gt;/>/g'
}

# ---------------------------------------------------------------------------
# Parse VTT file -> JSON array of {timestamp, offset, text}
# ---------------------------------------------------------------------------
parse_vtt() {
  local vtt_file="$1"

  if [[ ! -f "$vtt_file" ]]; then
    echo "[]"
    return
  fi

  awk '
  BEGIN {
    # State machine
    in_cue = 0
    prev_text = ""
    prev_start = -1
    count = 0
    printf "["
  }

  # Skip header lines
  /^WEBVTT/ { next }
  /^Kind:/ { next }
  /^Language:/ { next }
  /^NOTE/ { next }
  /^$/ {
    in_cue = 0
    next
  }

  # Timestamp line: 00:00:01.234 --> 00:00:04.567
  /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / {
    in_cue = 1
    # Parse start time
    split($1, t, ":")
    split(t[3], sec_ms, ".")
    start_seconds = int(t[1]) * 3600 + int(t[2]) * 60 + int(sec_ms[1])
    cue_text = ""
    next
  }

  # Also handle MM:SS.mmm --> format (no hours)
  /^[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / {
    in_cue = 1
    split($1, t, ":")
    split(t[2], sec_ms, ".")
    start_seconds = int(t[1]) * 60 + int(sec_ms[1])
    cue_text = ""
    next
  }

  # Text lines inside a cue
  in_cue == 1 {
    # Strip HTML tags (<c>, </c>, <c.colorXXXXXX>, position/alignment tags)
    gsub(/<[^>]*>/, "")
    # Strip leading/trailing whitespace
    gsub(/^[ \t]+/, "")
    gsub(/[ \t]+$/, "")

    if ($0 != "") {
      if (cue_text != "") {
        cue_text = cue_text " " $0
      } else {
        cue_text = $0
      }
    }
  }

  # When we hit a blank line or end, flush the cue
  # Actually we handle flush at timestamp detection and END
  # Re-approach: flush previous cue when we detect a new timestamp
  /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / || /^[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / {
    # This block already ran above via next, so we handle flush differently
  }

  END {
    printf "]"
  }
  ' "$vtt_file" | cat
  # The above awk approach is tricky for dedup; use a different strategy below.
  :
}

# ---------------------------------------------------------------------------
# Better VTT parser using a two-pass approach
# ---------------------------------------------------------------------------
parse_vtt_to_json() {
  local vtt_file="$1"

  if [[ ! -f "$vtt_file" ]]; then
    echo "[]"
    return
  fi

  # Use awk to extract raw cues, then deduplicate
  awk '
  BEGIN { in_cue = 0; cue_text = ""; start_sec = -1 }

  /^WEBVTT/ || /^Kind:/ || /^Language:/ || /^NOTE/ { next }

  # Timestamp line HH:MM:SS.mmm -->
  /^[0-9]+:[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / {
    # Flush previous cue
    if (start_sec >= 0 && cue_text != "") {
      print start_sec "\t" cue_text
    }
    # Parse start time
    split($1, t, ":")
    n = length(t)
    if (n == 3) {
      split(t[3], sec_ms, ".")
      start_sec = int(t[1]) * 3600 + int(t[2]) * 60 + int(sec_ms[1])
    } else if (n == 2) {
      split(t[2], sec_ms, ".")
      start_sec = int(t[1]) * 60 + int(sec_ms[1])
    }
    cue_text = ""
    in_cue = 1
    next
  }

  # Also handle MM:SS.mmm --> (no hours)
  /^[0-9][0-9]:[0-9][0-9]\.[0-9]+ --> / {
    if (start_sec >= 0 && cue_text != "") {
      print start_sec "\t" cue_text
    }
    split($1, t, ":")
    split(t[2], sec_ms, ".")
    start_sec = int(t[1]) * 60 + int(sec_ms[1])
    cue_text = ""
    in_cue = 1
    next
  }

  # Blank line ends cue
  /^[[:space:]]*$/ {
    if (in_cue == 1 && start_sec >= 0 && cue_text != "") {
      print start_sec "\t" cue_text
    }
    in_cue = 0
    next
  }

  # Sequence numbers (just digits on a line)
  /^[0-9]+$/ { next }

  # Text line
  in_cue == 1 {
    line = $0
    # Strip HTML tags
    gsub(/<[^>]*>/, "", line)
    # Strip leading/trailing whitespace
    gsub(/^[ \t]+/, "", line)
    gsub(/[ \t]+$/, "", line)
    if (line != "") {
      if (cue_text != "") {
        cue_text = cue_text " " line
      } else {
        cue_text = line
      }
    }
  }

  END {
    if (start_sec >= 0 && cue_text != "") {
      print start_sec "\t" cue_text
    }
  }
  ' "$vtt_file" | awk -F'\t' '
  # Deduplicate: skip segments where text is identical to previous
  BEGIN { prev_text = ""; prev_sec = -1 }
  {
    sec = $1
    txt = $2
    if (txt != prev_text) {
      print sec "\t" txt
      prev_text = txt
      prev_sec = sec
    }
  }
  '
}

# ---------------------------------------------------------------------------
# Build transcript output in requested format
# ---------------------------------------------------------------------------
build_transcript_output() {
  local vtt_file="$1"
  local fmt="$2"

  local parsed
  parsed="$(parse_vtt_to_json "$vtt_file")"

  case "$fmt" in
    plain)
      echo "$parsed" | while IFS=$'\t' read -r _sec text; do
        echo "$text" | decode_html_entities
      done | paste -sd ' ' -
      ;;
    timestamped)
      echo "$parsed" | while IFS=$'\t' read -r sec text; do
        local ts
        ts="$(format_timestamp "$sec")"
        echo "[$ts] $(echo "$text" | decode_html_entities)"
      done
      ;;
    json)
      local first=true
      echo "["
      echo "$parsed" | while IFS=$'\t' read -r sec text; do
        local ts
        ts="$(format_timestamp "$sec")"
        local clean_text
        clean_text="$(echo "$text" | decode_html_entities)"
        # Escape JSON special characters in text
        clean_text="$(echo "$clean_text" | sed 's/\\/\\\\/g; s/"/\\"/g')"
        if [[ "$first" == "true" ]]; then
          first=false
        else
          echo ","
        fi
        printf '  {"timestamp":"%s","offset":%d,"text":"%s"}' "$ts" "$sec" "$clean_text"
      done
      echo ""
      echo "]"
      ;;
    *)
      echo "Error: Unknown format '$fmt'. Use: plain, timestamped, json" >&2
      exit 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Build metadata JSON from yt-dlp dump-json output
# ---------------------------------------------------------------------------
build_metadata_json() {
  local json_data="$1"

  echo "$json_data" | jq '{
    title: .title,
    channel: .channel,
    channel_id: .channel_id,
    channel_followers: (.channel_follower_count // 0),
    upload_date: (if .upload_date then
      (.upload_date | split("") |
        .[0:4] | join("")) + "-" +
      (.upload_date | split("") |
        .[4:6] | join("")) + "-" +
      (.upload_date | split("") |
        .[6:8] | join(""))
    else "" end),
    duration: (.duration // 0),
    duration_formatted: (
      if (.duration // 0) >= 3600 then
        "\((.duration // 0) / 3600 | floor | tostring | if length < 2 then "0" + . else . end):\(((.duration // 0) % 3600) / 60 | floor | tostring | if length < 2 then "0" + . else . end):\((.duration // 0) % 60 | floor | tostring | if length < 2 then "0" + . else . end)"
      else
        "\(((.duration // 0) / 60 | floor | tostring) | if length < 2 then "0" + . else . end):\(((.duration // 0) % 60 | floor | tostring) | if length < 2 then "0" + . else . end)"
      end
    ),
    view_count: (.view_count // 0),
    like_count: (.like_count // 0),
    comment_count: (.comment_count // 0),
    description: (.description // ""),
    tags: (.tags // []),
    chapters: (if .chapters then [.chapters[] | {title: .title, start_time: .start_time, end_time: .end_time}] else null end),
    thumbnail: (.thumbnail // "")
  }'
}

# ---------------------------------------------------------------------------
# Find VTT file (try exact lang match, then auto-generated)
# ---------------------------------------------------------------------------
find_vtt_file() {
  local prefix="$1"
  local lang="$2"

  # Try exact match first: prefix.lang.vtt
  local exact="${prefix}.${lang}.vtt"
  if [[ -f "$exact" ]]; then
    echo "$exact"
    return
  fi

  # Try auto-generated variants
  for f in "${prefix}"*.${lang}*.vtt; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return
    fi
  done

  # Try any VTT file at the prefix
  for f in "${prefix}"*.vtt; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return
    fi
  done

  echo ""
}

# ===========================================================================
# Main execution
# ===========================================================================

case "$MODE" in
  # -----------------------------------------------------------------------
  # TRANSCRIPT mode
  # -----------------------------------------------------------------------
  transcript)
    # Download subtitles only
    if ! yt-dlp \
      --write-auto-sub \
      --write-sub \
      --sub-lang "$LANG" \
      --skip-download \
      --sub-format vtt \
      -o "${TEMP_PREFIX}" \
      "$URL" 2>/tmp/media-extract-ytdlp-err-${VIDEO_ID}; then
      cat /tmp/media-extract-ytdlp-err-${VIDEO_ID} >&2
      rm -f /tmp/media-extract-ytdlp-err-${VIDEO_ID}
      cleanup_temp
      exit 1
    fi
    rm -f /tmp/media-extract-ytdlp-err-${VIDEO_ID}

    VTT_FILE="$(find_vtt_file "$TEMP_PREFIX" "$LANG")"

    if [[ -z "$VTT_FILE" ]]; then
      echo "Warning: No subtitles available for language '$LANG'" >&2
      echo "[]"
      cleanup_temp
      exit 0
    fi

    build_transcript_output "$VTT_FILE" "$FORMAT"
    cleanup_temp
    ;;

  # -----------------------------------------------------------------------
  # METADATA mode
  # -----------------------------------------------------------------------
  metadata)
    JSON_DATA="$(yt-dlp --dump-json --no-download "$URL" 2>/dev/null)" || {
      echo "Error: Failed to fetch video data. Video may be private or URL is invalid." >&2
      exit 1
    }

    build_metadata_json "$JSON_DATA"
    ;;

  # -----------------------------------------------------------------------
  # ALL mode (single yt-dlp call for both)
  # -----------------------------------------------------------------------
  all)
    JSON_DATA="$(yt-dlp \
      --dump-json \
      --write-auto-sub \
      --write-sub \
      --sub-lang "$LANG" \
      --skip-download \
      --sub-format vtt \
      -o "${TEMP_PREFIX}" \
      "$URL" 2>/tmp/media-extract-ytdlp-err-${VIDEO_ID})" || {
      cat /tmp/media-extract-ytdlp-err-${VIDEO_ID} >&2
      rm -f /tmp/media-extract-ytdlp-err-${VIDEO_ID}
      cleanup_temp
      exit 1
    }
    rm -f /tmp/media-extract-ytdlp-err-${VIDEO_ID}

    METADATA="$(build_metadata_json "$JSON_DATA")"

    VTT_FILE="$(find_vtt_file "$TEMP_PREFIX" "$LANG")"

    if [[ -z "$VTT_FILE" ]]; then
      echo "Warning: No subtitles available for language '$LANG'" >&2
      # Output metadata only, with empty transcript
      jq -n --argjson meta "$METADATA" '{"metadata": $meta, "transcript": []}'
      cleanup_temp
      exit 0
    fi

    # Build transcript as JSON array
    TRANSCRIPT="$(build_transcript_output "$VTT_FILE" "json")"

    # Combine into final output
    jq -n --argjson meta "$METADATA" --argjson transcript "$TRANSCRIPT" \
      '{"metadata": $meta, "transcript": $transcript}'

    cleanup_temp
    ;;

  *)
    echo "Error: Unknown mode '$MODE'. Use: transcript, metadata, all" >&2
    exit 1
    ;;
esac
