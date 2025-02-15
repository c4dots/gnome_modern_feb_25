#!/bin/bash

# Clone repo
git clone https://github.com/c4dots/gnome_modern_feb_25/
cd gnome_modern_feb_25

# Args
USE_THEME=true
USE_ICONS=true
USE_BACKGROUND=true
USE_DIODON=true
DO_UPDATE=true
USE_SEARCH_LIGHT=true
DO_REBOOT=true
IGNORE_WRONG_ATTR=false
PACKAGES=("nautilus" "git" "python3" "ttf-ubuntu-font-family" "gnome-shell-extensions" "gnome-text-editor" "gnome-tweaks" "gnome-shell-extension-desktop-icons-ng" "gnome-shell-extension-arc-menu" "gnome-shell-extension-dash-to-panel")
for ARG in "$@"; do
  case $ARG in
    --no-theme)
      USE_THEME=false
      ;;
    --no-icons)
      USE_ICONS=false
      ;;
    --no-background)
      USE_BACKGROUND=false
      ;;
    --no-diodon)
      USE_DIODON=false
      ;;
    --no-update)
      DO_UPDATE=false
      ;;
    --no-search-light)
      USE_SEARCH_LIGHT=false
      ;;
    --no-reboot)
      DO_REBOOT=false
      ;;
    --ignore-wrong-attr)
      IGNORE_WRONG_ATTR=true
      ;;
    *)
      if [[ "$IGNORE_WRONG_ATTR" == false ]]; then
          echo ">> Usage: $0 [--no-theme] [--no-icons] [--no-background] [--no-diodon] [--no-update] [--no-search-light] [--no-reboot] [--ignore-wrong-attr]"
          exit 1
      fi
      ;;
  esac
done

#################### INFO ####################
# Info
echo ">> Your Configuration:"
echo " | USE_THEME=$USE_THEME"
echo " | USE_ICONS=$USE_ICONS"
echo " | USE_BACKGROUND=$USE_BACKGROUND"
echo " | USE_DIODON=$USE_DIODON"
echo " | DO_UPDATE=$DO_UPDATE"
echo " | DO_REBOOT=$DO_REBOOT"
echo " | USE_SEARCH_LIGHT=$USE_SEARCH_LIGHT"
echo " | PACKAGES=$PACKAGES"
#################### INFO ####################

#################### THEMES ####################
# Shell Theme
if [ "$USE_THEME" = true ]; then
    echo ">> Installing theme..."

    if [ ! -d "$HOME/.themes/Colloid-Dark" ]; then
        git clone https://github.com/vinceliuice/Colloid-gtk-theme
        cd Colloid-gtk-theme
        sh install.sh
        cd ..
    else
        echo ">> Theme already installed, skipping."
    fi

    #git clone https://github.com/vinceliuice/Graphite-gtk-theme
    #cd Graphite-gtk-theme
    #sh install.sh --name "Graphite-teal-Dark-nord" --tweaks rimless nord -c dark
    #cd ..
fi

# Icon Theme
if [ "$USE_ICONS" = true ]; then
    if [ ! -d "$HOME/.icons/Futura" ]; then
        echo ">> Installing icon theme..."
        git clone https://github.com/coderhisham/Futura-Icon-Pack
        cp -R Futura-Icon-Pack ~/.icons/Futura
    else
        echo ">> Icon theme already installed, skipping."
    fi
fi

# Background
if [ "$USE_BACKGROUND" = true ]; then
    echo ">> Changing Background"
    cp background.png ~/.config/background
fi
#################### THEMES ####################


#################### PACKAGES ####################
# Update
if [ "$DO_UPDATE" = true ]; then
    echo ">> Updating system..."
    sudo pacman -Syu --noconfirm
fi

# Install packages
for PACKAGE in "${PACKAGES[@]}"; do
    if pacman -Qi "$PACKAGE" &> /dev/null; then
        echo ">> $PACKAGE is already installed."
    else
        sudo pacman -S "$PACKAGE" --noconfirm
        echo ">> $PACKAGE has been installed."
    fi
done

# Install diodon
if [ "$USE_DIODON" = true ]; then
    yay -S diodon --noconfirm
fi

# Search light
if [ "$USE_SEARCH_LIGHT" = true ]; then
    echo ">> Installing Search Light extension..."
    git clone https://github.com/icedman/search-light
    cd search-light
    make
    cd ..
fi
#################### PACKAGES ####################


#################### CONFIG ####################
# Enable extensions
echo ">> Enabling extensions..."
gnome-extensions enable search-light@icedman.github.com
gnome-extensions enable ding@rastersoft.com
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com

echo ">> Loading configs..."
dconf load / < ./conf/apps/gedit
dconf load / < ./conf/apps/nautilus
dconf load / < ./conf/extensions/arcmenu
dconf load / < ./conf/extensions/ding
dconf load / < ./conf/extensions/diodon
dconf load / < ./conf/extensions/dtp
dconf load / < ./conf/extensions/searchlight
dconf load / < ./conf/desktop
#################### CONFIG ####################


echo ">> Done."

if [ "$DO_REBOOT" = true ]; then
    sudo reboot now
fi
