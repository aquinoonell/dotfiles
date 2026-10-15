#!/bin/bash
# Open Rift's overview / mission-control menu.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
rift-cli execute mission-control show-all 2>/dev/null || true
