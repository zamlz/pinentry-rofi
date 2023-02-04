#!/bin/sh
    
# pinentry-rofi: Use rofi dmenu as a pinentry tool
# Copyright (C) 2022  Amlesh Sivanantham 

# TODO: Fix message generation part of this script, its a fuckin mess (use printf probably)
# TODO: Also make sure colors are being pulled from user loaded colorscheme
# TODO: Figure out how to properly set the display variable

# Source this file to use my colorscheme
# . $HOME/lib/shell/xrdb_colors

ENABLE_LOGGING="FALSE"
logger() {
    if [ "$ENABLE_LOGGING" = "TRUE" ]; then
        /usr/bin/logger --tag "${0} [$$]" "$@";
    fi
}

# Base command and misc variables
ROFI="/usr/bin/rofi -dmenu -input /dev/null -password -lines 0"
DESC=""
ERROR=""
PROMPT=""

if [ -z "${DISPLAY}" ]; then
    # This is real jank hack. Got to figure out how to naturally get this var.
    if [ -n "$(uname -v | grep -i "UBUNTU")" ]; then
        export DISPLAY=":1"
    else
        export DISPLAY=":0"
    fi
fi

logger "pinentry-rofi started"
logger "DISPLAY=< $DISPLAY >"


echo "OK Please go ahead"
while read cmd rest; do
    logger "RAW=< ${cmd} ${rest} >"
    logger "cmd=<${cmd}> rest=<${rest}>"

    if [ -z "$cmd" ]; then
        continue;
    fi

    case "$cmd" in
        \#*)
            echo "OK"
            ;;

        GETINFO)
            case "$rest" in
                flavor)
                    echo "D rofi"
                    echo "OK"
                    ;;
                version)
                    echo "D 0.1"
                    echo "OK"
                    ;;
                ttyinfo)
                    echo "D - - -"
                    echo "OK"
                    ;;
                pid)
                    echo "D $$"
                    echo "OK"
                    ;;
            esac
            ;;

        SETDESC)
            DESC=$rest
            echo "OK"
            ;;

        SETERROR)
            # Added _ERO_ and _ERC_ as markers to help the sed operation in
            # the GETPIN command.
            ERROR=$( echo "_ERO_${rest}_ERC_" | awk '{print toupper($0)}')
            echo "OK"
            ;;

        SETPROMPT)
            # rofi already adds a :
            PROMPT=$(echo "$rest" | tr -d ':')
            echo "OK"
            ;;

        GETPIN)
            # This shit right here is to deal with some pango markup related
            # bullshit. I literalyl don't underestand why there isn't an
            # option to just turn off pango in rofi but of well...
            # In any case, this adds some markup for flavor and to also correct
            # the text so that rofi doesn't complain about the input it gets.
            # Ironically, its also the only way I have figured out how to
            # insert newlines...
            MESSAGE=$( echo "$ERROR$DESC" | sed -e "s|%0A|\n|g"              \
                                    -e "s|%22||g"                            \
                                    -e "s|key:|key:\n|g"                     \
                                    -e "s|>|>\n|g"                           \
                                    -e "s|<|\&lt;|g"                         \
                                    -e "s|>|\&gt;|g"                         \
                                    -e "s|,created|,\ncreated|g"             \
                                    -e "s|_ERO_|<span fgcolor='#ab4642'>|g"  \
                                    -e "s|_ERC_|</span>\n|g"                 )

            rofi_cmd="$ROFI -p \"$PROMPT\" -mesg \"$MESSAGE\""
            logger "GETPIN, calling rofi: ${rofi_cmd}"

            _PP=$( $ROFI -p "$PROMPT" -mesg "$MESSAGE" )
            logger "ROFI : ERC=<$?>, _PP=<${_PP}>"

            if [ -n "$_PP" ]; then
                echo "D $_PP"
            fi
            echo "OK"
            ;;

        BYE)
            logger "BYE, exiting"
            # FIXME: broken pipe appears here as connection is closing.
            #        gpg may be closing earlier than pinentry expects?
            echo "OK closing connection"
            exit 0
            ;;

        *)
            echo "OK"
            ;;
    esac
done
logger "EOF, exiting"
