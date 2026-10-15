#!/bin/bash
# Best-effort: open the native Wi‑Fi menu / Control Center Wi‑Fi pane.

# 1) System Settings Wi‑Fi (always shows nearby networks)
open "x-apple.systempreferences:com.apple.wifi-settings-extension" 2>/dev/null \
  || open "x-apple.systempreferences:com.apple.Network-Settings.extension" 2>/dev/null \
  || true

# 2) If Control Center exposes a Wi‑Fi menu bar item, click it
osascript <<'EOF' >/dev/null 2>&1 || true
tell application "System Events"
  try
    tell process "Control Center"
      set frontmost to true
      repeat with mb in every menu bar
        repeat with mbi in every menu bar item of mb
          set d to ""
          try
            set d to description of mbi
          end try
          set n to ""
          try
            set n to name of mbi as text
          end try
          if d contains "Wi-Fi" or d contains "Wi‑Fi" or n contains "Wi-Fi" or n contains "Wi‑Fi" then
            click mbi
            return
          end if
        end repeat
      end repeat
    end tell
  end try
end tell
EOF
