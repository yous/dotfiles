#!/bin/bash
# Usage: notify.sh <message>
# Cross-platform desktop notification for Claude Code hooks.
message="${1:-Claude Code}"
title='Claude Code'

case "$(uname)" in
  Darwin)
    osascript - "$message" "$title" <<'EOF'
on run argv
  display notification (item 1 of argv) with title (item 2 of argv) sound name "Tri-Tone"
end run
EOF
    ;;
  Linux)
    if command -v notify-send >/dev/null; then
      if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        notify-send "$title" "$message"
      fi
    fi
    ;;
esac

exit 0
