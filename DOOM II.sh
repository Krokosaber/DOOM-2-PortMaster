#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/ports/doom2"

# CD and set permissions
cd $GAMEDIR
exec > "$GAMEDIR/log.txt" 2>&1
$ESUDO chmod +xwr -R $GAMEDIR/*

# Exports
export LD_LIBRARY_PATH="$controlfolder/runtimes/love_11.5/libs.aarch64:$GAMEDIR/libs/lovelibs:/mnt/SDCARD/System/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb.txt"

# Bind config path
bind_directories ~/.config/gzdoom $GAMEDIR/configs/doom/gzdoom

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/gamecontrollerdb.txt"

# Add supplemental arguments for gzdoom
ARGS="-iwad $GAMEDIR/doomfiles/DOOM2.wad +gl_es 1 +vid_preferbackend 3 +cl_capfps 0 +vid_fps 0 +logfile gzdoom_log.txt"

$GPTOKEYB2 "gzdoom" -c "controls.ini" &

# Disable gamepad
export LD_PRELOAD="$GAMEDIR/libs/hacksdl.so"
export HACKSDL_NO_GAMECONTROLLER=1
export HACKSDL_VERBOSE=0

# Run the game
echo "[LOG]: Running gzdoom with args: ${ARGS}"
pm_platform_helper "$GAMEDIR/gzdoom" > /dev/null

./gzdoom $ARGS

# Cleanup
pm_finish
