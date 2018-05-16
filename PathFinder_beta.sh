#!/bin/bash
# Pathfinder 4 Custom Collections
# BETA - release
# level 6 is disabeled
# by cyperghost
# Without using IFS or other bad tricks!
# iname, iregex vs name, regex is independent of upper lower cases

readonly VERSION="0.75_051518"
readonly TITLE="Pathfinder 4 Custom Collections"
readonly ROMBASE_DIR="/home/pi/RetroPie/roms"
readonly COLLECTION_DIR="/opt/retropie/configs/all/emulationstation/collections"

# ---- Function Calls ----

# get extension for specfic system
# if system isn't available then file extension is ignored
# we got all files from base rom without

function system_extension () {

    case "$1" in

        amstradcpc) echo ".*\.\(cdt\|cpc\|dsk\)" ;;
        arcade) echo ".*\.\(fba\|zip\)" ;;
        atari2600) echo ".*\.\(7z\|a26\|bin\|rom\|zip\|gz\)" ;;
        atari7800) echo ".*\.\(7z\|a78\|bin\|zip\)" ;;
        atarilynx) echo ".*\.\(7z\|lnx\|zip\)" ;;
        cps1) echo ".*\.\(fba\|zip\)" ;;
        cps2) echo ".*\.\(fba\|zip\)" ;;
        fba) echo ".*\.\(fba\|zip\)" ;;
        fds) echo ".*\.\(nes\|fds\|zip\)" ;;
        gameandwatch) echo ".*\.\(mgw\)" ;;
        gamegear) echo ".*\.\(7z\|gg\|bin\|sms\|zip\)" ;;
        gb) echo ".*\.\(7z\|gb\|zip\)" ;;
        gba) echo ".*\.\(7z\|gba\|zip\)" ;;
        gbc) echo ".*\.\(7z\|gbc\|zip\)" ;;
        mame-libretro) echo ".*\.\(zip\)" ;;
        mame-mame4all) echo ".*\.\(zip\)" ;;
        mastersystem) echo ".*\.\(7z\|sms\|bin\|zip\)" ;;
        megadrive) echo ".*\.\(7z\|smd\|bin\|gen\|md\|sg\|zip\)" ;;
        msx) echo ".*\.\(rom\|mx1\|mx2\|col\|dsk\|zip\)" ;;
        n64) echo ".*\.\(z64\|n64\|v64\)" ;;
        neogeo) echo ".*\.\(fba\|zip\)" ;;
        nes) echo ".*\.\(7z\|nes\|zip\)" ;;
        ngp) echo ".*\.\(ngp\|zip\)" ;;
        ngpc) echo ".*\.\(ngc\|zip\)" ;;
        pcengine) echo ".*\.\(7z\|pce\|ccd\|cue\|zip\)" ;;
        ports) echo ".*\.\(sh\)" ;;
        psp) echo ".*\.\(iso\|pbp\|cso\)" ;;
        psx) echo ".*\.\(cue\|cbn\|img\|iso\|m3u\|mdf\|pbp\|toc\|z\|znx\)" ;;
        sega32x) echo ".*\.\(7z\|32x\|smd\|bin\|md\|zip\)" ;;
        segacd) echo ".*\.\(iso\|cue\)" ;;
        sg-1000) echo ".*\.\(sg\|bin\|zip\)" ;;
        snes) echo ".*\.\(7z\|bin\|smc\|sfc\|fig\|swc\|mgd\|zip\)" ;;
        vectrex) echo ".*\.\(7z\|vec\|gam\|bin\|zip\)" ;;
        zxspectrum) echo ".*\.\(7z\|sh\|sna\|szx\|z80\|tap\|tzx\|gz\|udi\|mgt\|img\|trd\|scl\|dsk\|zip\|rzx\)" ;;

    esac
}

# Rebuild Filenames, if $i starts with "./" an new filename is found
# Array postion 1 is always empty, we can use that later

function build_find_array() {

    local i;local ii
    local filefind="$1"

    for i in $filefind; do
        if [[ ${i:0:2} == "./" ]]; then
            array+=("$ii")
            ii=
            ii="$i"
         else
            ii="$ii $i"
         fi
    done
    array[0]="$ii"

}

# File Search Function with different levels
# Wie return, number of filesfound and array
# level 1=simple 1:1 find (autmatic)
# level 2=intermediate: /path/system/rom*.{systemext}
# level 3=intermediate: /path/system/*rom*.{systemext} and removed ,
# level 4=advanced: /path/rom.ext - for aracades
# level 5=advanced: /path/rom.{systemext} - for arcades
# level 6=lastresort: /path/rom* - disabled

function file_search() {

    local level="$1"
    local filefind

    case $level in

        1) unset array
           if [[ -d $ROMBASE_DIR/$rom_system ]] && [[ $ROMBASE_DIR/$rom_system == $rom_path ]]; then
               cd "$rom_path"
               filefind=$(find -name "$rom_name" -type f 2>/dev/null)
               [[ -n $filefind ]] && array[0]="$rom_path${filefind#.*}"
           fi

           [[ -z $filefind ]] && file_search 2
        ;;

        2) unset array
           if [[ -d $ROMBASE_DIR/$rom_system ]] && [[ $ROMBASE_DIR/$rom_system == $rom_path ]]; then
               cd "$rom_path"
               system_extension=$(system_extension "$rom_system")
               filefind=$(find -iname "$rom_no_brkts*" -iregex "$system_extension" -type f 2>/dev/null)

               if [[ -n $filefind ]]; then
                   # Build Array for files
                   build_find_array "$filefind"

                   # Remove ./ from filenames and add pathes to array
                   z=0
                   for i in "${array[@]}"; do
                       array[z]="$rom_path${i#.*}"
                       z=$((z+1))
                   done
               fi
           fi
           [[ -z $filefind ]] && file_search 3
        ;;

        3) unset array
           if [[ -d $ROMBASE_DIR/$rom_system ]] && [[ $ROMBASE_DIR/$rom_system == $rom_path ]]; then
               cd "$rom_path"
               system_extension=$(system_extension "$rom_system")
               rom_no_brkts="${rom_no_brkts%,*}"
               filefind=$(find -iname "*$rom_no_brkts*" -iregex "$system_extension" -type f 2>/dev/null)

               if [[ -n $filefind ]]; then
                   # Build Array for files
                   build_find_array "$filefind"

                   # Remove ./ from filenames and add pathes to array
                   z=0
                   for i in "${array[@]}"; do
                       array[z]="$rom_path${i#.*}"
                       z=$((z+1))
                   done
               fi
           fi

           [[ -z $filefind ]] && file_search 4

        ;;

        4) unset array
           if [[ -d $ROMBASE_DIR ]] && [[ $ROMBASE_DIR == $rom_base ]]; then
               cd "$rom_base"
               filefind=$(find -iname "$rom_name" -type f 2>/dev/null)
               if [[ -n $filefind ]]; then
                   # Build Array for files
                   build_find_array "$filefind"

                   # Remove ./ from filenames and add pathes to array
                   z=0
                   for i in "${array[@]}"; do
                       array[z]="$rom_base${i#.*}"
                       z=$((z+1))
                   done
               fi
           fi

           [[ -z $filefind ]] && file_search 5
       ;;

        5) unset array
           if [[ -d $ROMBASE_DIR ]] && [[ $ROMBASE_DIR == $rom_base ]]; then
               cd "$rom_base"
               system_extension=$(system_extension "$rom_system")
               filefind=$(find -iname "$rom_name" -iregex "$system_extension" -type f 2>/dev/null)
               if [[ -n $filefind ]]; then
                   # Build Array for files
                   build_find_array "$filefind"

                   # Remove ./ from filenames and add pathes to array
                   z=0
                   for i in "${array[@]}"; do
                       array[z]="$rom_base${i#.*}"
                       z=$((z+1))
                   done
               fi
           fi

           [[ -z $filefind ]] && unset array
       ;;

        6) unset array
           if [[ -d $ROMBASE_DIR ]]; then
               cd "$ROMBASE_DIR"
               filefind=$(find -iname "$rom_no_brkts*" -type f ! -iregex ".*\.\(srm\|state*\|auto*\nv\hi\)" 2>/dev/null)
               # Build Array for files
               build_find_array "$filefind"

               # Remove ./ from filenames and add pathes to array
               z=0
               for i in "${array[@]}"; do
                   array[z]="$ROMBASE_DIR${i#.*}"
                   z=$((z+1))
               done

           fi

           [[ -z $filefind ]] && unset array
       ;;

    esac
}
# ---- Dialog Functions ----

# Dialog Error
# Display dialog --msgbox with text parsed with by function call

function dialog_error() {
    dialog --title " Error " --backtitle " $TITLE - $VERSION " --msgbox "$1" 0 0
}

# ---- Dialog Select Custom Collection ---

# This builds dialog for custom collections
# We need to create valid array (dialog_array) before
# I disabled tags, so custom collections are showen exactly as in ES

function dialog_customcollection() {

    # Create array for dialog
    local dialog_array
    local i
    for i in "${array[@]}"; do
        dialog_array+=("$i" "${i:9:-4}")
    done

    # old file array isn't needed anymore!
    unset array

    # -- Begin Dialog
    local cmd=(dialog --backtitle "$TITLE - $VERSION " \
                      --title " Select Custom Collection " \
                      --ok-label "Select " \
                      --cancel-label "Exit to ES" \
                      --no-tags --stdout \
                      --menu "There are $((${#dialog_array[@]}/2)) collection files available\nPlease select one:" 16 70 16)
    local choices=$("${cmd[@]}" "${dialog_array[@]}")
    echo "$choices"
    # -- End Dialog
}

# ----------------------------------------------------------------------------------------------------

# Get collection files and build valid array

cd "$COLLECTION_DIR"
find_collection=$(find -name "custom-*.cfg" -type f 2>/dev/null)

# Are there any collection files available?
if [[ -z $find_collection ]]; then
    dialog_error "No Collection files found in location:\n$COLLECTION_DIR"
    exit
fi

build_find_array "$find_collection"
collection_file=$("dialog_customcollection")
collection_file="$COLLECTION_DIR${collection_file#.*}"

# Okay We have our collection file, now we are processing it.

cd "$ROMBASE_DIR"
while read line; do
    unset array

    # As much description as possible
    rom_name="$(basename "$line")"
    rom_path="$(dirname "$line")"
    rom_base="$(dirname "$rom_path")"
    rom_no_ext="${rom_name%.*}"
    rom_ext="${rom_name#*.}"
    rom_no_brkts="${rom_name%% (*}"
    rom_system="${rom_path##*/}"


    # Start file investigation
    # You can set level 1 to 6
    # 1-simple to 6-advanced

    file_search 1

    # Results:
    [[ ${#array[@]} -eq 0 ]] && echo "File not found: $line" && unset array
    [[ ${array[0]} == $line ]] && echo "Found level 1: ${array[@]}" && unset array
    [[ ${#array[@]} -eq 1 ]] && echo "Found write with sed: $line -- ${array[@]}" && unset array
    [[ ${#array[@]} -gt 1 ]] && echo "Dialog hold ${#array[@]} files: $line -- ${array[@]}" && unset array


done < <(tr -d '\r' < "$collection_file")
