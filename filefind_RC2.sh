#!/bin/bash
# Pathfinder 4 Custom Collections
# How to find files maybe usefull for custom collections
# by cyperghost
# Without using IFS or other bad tricks!
# iname, iregex vs name, regex is independent of upper lower cases
#

readonly VERSION="0.96_051918"
readonly TITLE="Pathfinder 4 Custom Collections"
readonly ROMBASE_DIR="/home/pi/RetroPie/roms"
readonly COLLECTION_DIR="/opt/retropie/configs/all/emulationstation/collections"
readonly ignore_list=("the" "The" "and" "is" "II" "III")

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
        *) echo "not found" ;;

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
# level 2.1=intermediate: /path/system/rom*.{systemext}
# level 2.2=super intermediate: /path/system/*rom*.{systemext}, 
# level 3.1=arcade: /path/rom.{systemext}
# level 3.2=arcade: /path/rom*.{systemext}
# experimental level 4.1=advanced: /path/rom*.{systemext}
# experimental level 4.2=lastresort: /path/*rom*

function file_search() {

    local level="$1"
    local filefind

    case $level in

        1)
           # This is LEVEL 1 search - this are direct hits

           if [[ -d $ROMBASE_DIR/$rom_system ]] && [[ $ROMBASE_DIR/$rom_system == $rom_path ]]; then
               cd "$rom_path"
               filefind=$(find -name "$rom_name" -type f 2>/dev/null)
               [[ -n $filefind ]] && array[0]="$rom_path${filefind#.*}"
           fi

           [[ -z $filefind ]] && file_search 2
        ;;

        2)
           # This is LEVEL 2 search - search per system!
           # Search 2.1: Brackets removed, all file extension for system available are considered
           # Search 2.2: All special character will be removed and resolved as *
           #             Word like "The" "of" and some roman numbers will be stripped *
           #             Like in 2.1 all file extensions for system will be considered      

           if [[ -d $ROMBASE_DIR/$rom_system ]] && [[ $ROMBASE_DIR/$rom_system == $rom_path ]]; then
               cd "$rom_path"
               system_extension=$(system_extension "$rom_system")

               filefind=$(find -iname "$rom_no_brkts*" -iregex "$system_extension" -type f 2>/dev/null)

               if [[ -z $filefind ]]; then
                   rom_no_brkts="${rom_no_brkts//[^[:alnum:].]/\*}"
                   for i in "${ignore_list[@]}"; do
                       rom_no_brkts="${rom_no_brkts//$i/\*}"
                   done

                   filefind=$(find -iname "*$rom_no_brkts*" -iregex "$system_extension" -type f 2>/dev/null) 

               fi

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

        3)
           # This is LEVEL 3 of file search - search in BASE folders
           # It's a suitable case for arcades for example
           # Search 3.1: Just filename with extension of system available
           # Search 3.2: Just filename* to catch subroms, all extension for system available

           if [[ -d $ROMBASE_DIR ]] && [[ $ROMBASE_DIR == $rom_base ]]; then
               cd "$rom_base"
               filefind=$(find -name "$rom_name" -type f 2>/dev/null)

               if [[ -z $filefind ]]; then
                   [[ $system_extension == "not found" ]] && break
                   filefind=$(find -iname "$rom_no_ext*" -iregex "$system_extension" -type f 2>/dev/null)
               fi

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


        6)
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

    # -- Begin Dialog
    local cmd=(dialog --backtitle "$TITLE - $VERSION " \
                      --title " Select Custom Collection " \
                      --ok-label "Select " \
                      --cancel-label "Exit to ES" \
                      --no-tags --stdout \
                      --menu "There are ${#array[@]} collection files available\nPlease select one:" 16 70 16)
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
# First: we go to our ROMBASE_DIR
# Second: we remove some garbage and unset the old array
# Third: we compare our files with the collections - so hard work ;)
#
cd "$ROMBASE_DIR"
unset array

while read line; do

    # Get as much description as possible from custom collection entries
    #
    rom_name="$(basename "$line")"       # Pure ROMs name with it's extension
    rom_path="$(dirname "$line")"        # This is ROMs path with system
    rom_base="$(dirname "$rom_path")"    # This represents all systemspathes
    rom_no_ext="${rom_name%.*}"          # ROM without extension
    rom_ext="${rom_name#*.}"             # The ROM extension (fallback)
    rom_no_brkts="${rom_no_ext%% (*}"    # ROMs Name without any brackets
    rom_system="${rom_path##*/}"         # ROMs system extracted out of path

    # Start file investigation
    # You can set level 1 to 4
    # 1-simple to 4-advanced

    file_search 1

    # Results:
    if [[ ${#array[@]} -eq 0 ]]; then
        echo "File not found: $line"
    elif [[ ${array[0]} == $line ]]; then
        echo "Found level 1: ${array[@]}"
    elif [[ ${#array[@]} -eq 1 ]]; then 
        echo "Found write with sed: $line -- ${array[@]}" && unset array
    elif  [[ ${#array[@]} -gt 1 ]]; then
        echo "Dialog hold ${#array[@]} files: $line -- ${array[@]}"
        temp_array+=("${#array[@]}")
        temp_array+=("$line")
        for i in "${array[@]}"; do
            temp_array+=("$i")
        done
    else
        echo "Critical error accourd!"
        echo "This might not happend!"
        exit
    fi

    unset array

done < <(tr -d '\r' < "$collection_file")

# Wow that was fun!
# My coding skills aren't as good so I might ask the user for file choice!
# Maybe everything went good and only 1 accournce of files were found
# So we can end here

[[ ${#temp_array[@]} -eq 0 ]] && echo "All done...." && exit

# But I think the chances that there are more than one accourence
# So let us do this job NOW!
# I setted number of all entries in first field
# So we read array[0] and get number of entries and build a dialog array
# array [0] presents number of entries for ex: 2 (that's a total of 3!}
# array [1] presents orignial name of custom collection
# array [2] is possible rom #1
# array [3] is possible rom #2
# array [4] present number of entries of next dialog ;)
#

z=-1
idx="${temp_array[0]}"

for i in "${temp_array[@]}"; do
    echo "$z -- $idx: $i"

    if [[ $z -gt $idx ]]; then
       echo "Begin new array with collection name and $i possible entries"
       idx="$i"
       z=-1
       echo "ARRAY! Build - call dialog"
    fi
    ((z++))
done
