#!/bin/bash

#/usr/share/doc/{pkg} 	Application documentation 

RECURSIVE=0
HELP=0
VERBOSE=0
LESS=0
DIRECTORY="./"
EXTENSION="md"
LOOSE_ARGS=()

#ARGS
for arg in "$@"; do
    case $arg in
        -h|--help)
        HELP=1
        shift
        ;;
        -l|--less)
        LESS=1
        shift
        ;;
        -r|--recursive)
        RECURSIVE=1
        shift
        ;;
        -v|--verbose)
        VERBOSE=1
        shift
        ;;
        -d=*|--directory=*)
        DIRECTORY="${arg#*=}"
        shift
        ;;
        -e=*|--extension=*)
        EXTENSION="${arg#*=}"
        shift
        ;;
        *)
        LOOSE_ARGS+=("$1")
        shift
        ;;
    esac
done

# HELP
if [ $HELP -ne 0 ]; then
    echo "MD2CONFIG HELP"
    echo "Usage: ./md2config.sh [FLAG]..."
    echo "By default without any FLAGs it will look for .md files in the"
    echo "current directory (case insensitive), generate configs files"
    echo "from them and a .bak backup if an old file already exists."
    echo "Any directoy, file or extension specified with a flag is case sensitive"
    echo ""
    echo "  -h, --help             Displays this help"
    echo "  -r, --recursive        Will search for files in all"
    echo "                         subdirectories from the current one"
    echo "  -d=,--directory=       Specifies a directory to look files on"
    echo "                         [Default: Same directory]"
    echo "  -e=,--extension=       Specifies an extension to look for"
    echo "                         [Default: .md]"
    echo "  -v,--verbose           Will display extra information during proccess"
    echo "                         [Default: Minimal information]"
    echo "  -l,--less              Will hide console output during proccess"
    echo "                         [Default: Minimal information]"
    echo "  <filename>             Pass file/s separated by spaces"
    echo ""
    echo -e "Valid files are those containing \e[1m[MD2CONFIG]: # (FILENAME: \"<filename>\")\e[0m"
    echo "in the first line. Where <filename> is the name of the file to be generated"
    echo -e "blockcodes within it. Example: \e[1m[MD2CONFIG]: # (FILENAME: \"custom.lua\")\e[0m"
    exit 0
fi

# VERBOSE ON
verboseOn(){
    if [ $VERBOSE -eq 1 ]; then return 0; fi
    return 1
}

# LESS OFF
lessOff(){
    if [ $LESS -eq 1 ]; then return 1; fi
    return 0
}

# VALID FILE
isFileValid(){
    # READ THE FIRST LINE
    if verboseOn; then echo -e "Checking if \e[1m$1\e[0m is a valid file"; fi

    firstLine=$(head -n 1 $1)

    if verboseOn; then echo -e "\e[1m$1\e[0m first line is \e[1m$firstLine\e[0m"; fi

    # LOOK IF IT'S OUR EXPECTED FORMAT
    re="\[MD2CONFIG\]\:.*\#.*\(FILENAME\:.?[\"\'](.*)[\"\']\)"

    if verboseOn; then echo -e "Checking if first line has the expected pattern \e[1m[MD2CONFIG]: # (FILENAME: \"<filename>\")\e[0m"; fi

    if [[ $firstLine =~ $re ]]; then

        if verboseOn; then echo "First line has the expected pattern, trying to extract filename from it"; fi

        filename=${BASH_REMATCH[1]}

        if [ $filename ]; then
            if verboseOn; then echo -e "Found filename \e[1m$filename\e[0m"; fi
            return 0
        else
            if verboseOn; then echo "Filename was empty"; fi
            return 1
        fi
    else
        if verboseOn; then echo -e "\e[1m$1\e[0m is not a valid file"; fi
        return 1
    fi
}

# DO FILE
doFile(){
    local file=$1
    # CHECK IF FILE EXISTS
    if [ -e $file ]; then
        # CHECK IF FILE IS VALID
        if isFileValid $file; then

            # START WORKING ON THIS FILE
            firstLine=$(head -n 1 $file)
            if [[ $firstLine =~ $re ]]; then

                # GET THE FILENAME INSIDE THE FILE
                filename=${BASH_REMATCH[1]}

                # GET DIRECTORY FOR THIS FILE
                fileDirectory=$(dirname $file)

                # IF FILE ALREADY EXISTS MAKE BACKUP
                if test -f "$fileDirectory/$filename"; then
                    cp $fileDirectory/$filename $fileDirectory/${filename}.bak
                    #rm -f $fileDirectory/$filename
                fi
                
                # DO THE MAGIC
                sed -n '/^```/,/^```$/p' $file | sed '/^```.*/d' >> $fileDirectory/$filename
                if lessOff; then echo "$file >> $fileDirectory/$filename"; fi




            fi
        else
            echo "$file invalid file"
            if ! verboseOn; then echo "Run with -v for more info"; fi
        fi
        
    else
        echo -e "\e[1m$file\e[0m is not a file"
    fi    
}

# POSSIBLE FILENAMES CAT IN THE COMMAND OR MISSING ARGUMENTS
if (( ${#LOOSE_ARGS[@]} )); then

    if [ $RECURSIVE -eq 0 ] && [ $DIRECTORY = "./" ] && [ $EXTENSION = "md" ]; then    
        for arg in ${LOOSE_ARGS[*]}; do
            doFile $arg
        done
        exit 0
    else
        echo "Invalid flag/s for the given arguments"
    fi
else
    exit 0
fi





#echo "# RECURSIVE: $RECURSIVE"
#echo "# DIRECTORY: $DIRECTORY"
#echo "# FILE: $FILE"
#echo "# EXTENSION: $EXTENSION"
#echo "# LOOSE_ARGS: ${LOOSE_ARGS[*]}"






