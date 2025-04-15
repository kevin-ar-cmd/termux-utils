#!/data/data/com.termux/files/usr/bin/bash

# Install required packages
pkg install -y termux-api play-audio

# Create sounds directory
mkdir -p ~/.termux/sounds

# Download beep and error sound files
curl -Lo ~/.termux/sounds/beep.mp3 https://www.soundjay.com/button/beep-07.mp3
curl -Lo ~/.termux/sounds/error.mp3 https://www.soundjay.com/button/beep-10.mp3

# Add beepwrap function to shell configuration
SHELL_RC="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
  SHELL_RC="$HOME/.zshrc"
fi

cat << 'EOF' >> "$SHELL_RC"

beepwrap() {
  local CMD="$@"
  local BEEP_SOUND="$HOME/.termux/sounds/beep.mp3"
  local ERROR_SOUND="$HOME/.termux/sounds/error.mp3"

  # Start background beep loop
  while true; do play-audio "$BEEP_SOUND"; sleep 1; done &
  local BEEP_PID=$!

  # Run the command
  eval "$CMD"
  local STATUS=$?

  # Kill the beeping loop
  kill $BEEP_PID 2>/dev/null
  wait $BEEP_PID 2>/dev/null

  # Play success or error sound
  if [ $STATUS -eq 0 ]; then
    termux-vibrate -d 150
  else
    play-audio "$ERROR_SOUND"
    termux-vibrate -d 500
  fi

  return $STATUS
}
EOF

# Reload shell configuration
source "$SHELL_RC"

echo "beepwrap function installed. Use it by running: beepwrap your_command"
