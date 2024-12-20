#!/bin/bash
xset -dpms      # Disable power management
xset s off      # Disable screen saver
xset s noblank  # Disable blanking
unclutter &     # Hide the mouse cursor
chromium-browser --kiosk --noerrdialogs --disable-infobars --disable-translate --incognito "https://gratitude-kappa.vercel.app/"
