#!/bin/bash

# Enable GNOME's dark mode preference
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Pick the best available dark GTK theme
if [ -d /usr/share/themes/Yaru-dark ]; then
    GTK_THEME="Yaru-dark"
elif [ -d /usr/share/themes/Adwaita-dark ]; then
    GTK_THEME="Adwaita-dark"
else
    # fallback to whatever GNOME is using
    GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
fi

# Fetch other GNOME settings
ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
FONT_NAME=$(gsettings get org.gnome.desktop.interface font-name | tr -d "'")
CURSOR_THEME=$(gsettings get org.gnome.desktop.interface cursor-theme | tr -d "'")

# GTK3 config
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$FONT_NAME
gtk-application-prefer-dark-theme=true
EOF

# GTK4 config
mkdir -p ~/.config/gtk-4.0
cat > ~/.config/gtk-4.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$FONT_NAME
gtk-application-prefer-dark-theme=true
EOF

# Cursor theme
mkdir -p ~/.icons/default
cat > ~/.icons/default/index.theme <<EOF
[Icon Theme]
Name=$CURSOR_THEME
Inherits=$CURSOR_THEME
EOF

# Export cursor for X session
if ! grep -q XCURSOR_THEME ~/.profile; then
    echo "export XCURSOR_THEME=$CURSOR_THEME" >> ~/.profile
fi

export XCURSOR_THEME=$CURSOR_THEME

# Notify to confirm
notify-send "Dark Mode Applied" "Theme: $GTK_THEME, Icons: $ICON_THEME"

