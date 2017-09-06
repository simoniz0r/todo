#!/bin/bash
# A simple script that manages todo lists in ~/.todo/
# Written by simonizor http://simonizor.gq/linuxapps
# Dependencies: coreutils
# License: GPL v2 Only

helpfunc () {
printf "Usage: todo [OPTION] [ITEM]

todo manages todo lists in an easy to use manner.  Lists are stored in ~/.todo/ListName
with each item in the list stored as a separate file in that directory.

Options:
    todo                        # Lists all lists or items in specified list
    todo add list item          # Adds item to specified list
    todo add i=n list item      # Adds item to specified list with importance level n (4-0)
    todo edit list item#        # Opens the default editor to edit specified list item#
    todo done list item#        # Marks an item# in list or specified list with an X to indicate it is done
    todo undo list item#        # Removes X from specified item# in list to mark it as not done
    todo rm list item#          # Removes item# from list

Examples:
    todo                        # Lists all items in all todo lists
    todo mylist                 # Lists all items in mylist
    todo add mylist my item     # Adds my item to mylist
    todo add i=4 mylist item    # Adds item to mylist with importance level 4
    todo done mylist 1          # Marks item 1 in mylist with an X to indicate it is done
    todo undo mylist 1          # Removes X from item 1 in mylist to mark it as not done
    todo edit mylist 1          # Opens the default editor to edit item 1 in mylist
    todo rm mylist 1            # Removes item 1 from mylist
    todo rm mylist all          # Removes all items from mylist
"
}

todoaddfunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    if [ -d ~/.todo/"$LIST" ]; then
        FILE_NAME="$(($(dir ~/.todo/"$LIST" | wc -w)+1))"
    else
        mkdir ~/.todo/"$LIST"
        FILE_NAME="1"
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3- -d" ")"
    if [ -z "$TODO_ITEM" ]; then
        echo -e "Item input required!"
        echo
        helpfunc
        exit 1
    elif echo -e "$@" | cut -f3 -d" " | grep -q '='; then
        IMPORTANT_LEVEL="$(echo -e "$@" | cut -f2 -d"=" | cut -f1 -d" ")"
        TODO_ITEM="$(echo -e "$@" | cut -f4- -d" ")"
        case $IMPORTANT_LEVEL in
            4)
                echo -e "- \e[31m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
                echo -e "Item \"\e[31m$TODO_ITEM\e[39m\" added to $LIST list!"
                ;;
            3)
                echo -e "- \e[33m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
                echo -e "Item \"\e[33m$TODO_ITEM\e[39m\" added to $LIST list!"
                ;;
            2)
                echo -e "- \e[32m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
                echo -e "Item \"\e[32m$TODO_ITEM\e[39m\" added to $LIST list!"
                ;;
            0)
                echo -e "- \e[90m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
                echo -e "Item \"\e[90m$TODO_ITEM\e[39m\" added to $LIST list!"
                ;;
            *)
                echo -e "- \e[39m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
                echo -e "Item \"\e[39m$TODO_ITEM\e[39m\" added to $LIST list!"
                ;;
        esac
    else
        echo -e "- \e[39m$TODO_ITEM\e[39m" > ~/.todo/"$LIST"/"$FILE_NAME"
        echo -e "Item \"$TODO_ITEM\" added to $LIST list!"
    fi
}

todoeditfunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        $EDITOR ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo -e "Item $TODO_ITEM not found in $LIST!"
        exit 1
    fi
}

tododonefunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        DONE_TODO_ITEM="$(cat ~/.todo/"$LIST"/"$TODO_ITEM")"
        DONE_TODO_ITEM="${DONE_TODO_ITEM:1}"
        sed -i 's%- %✘ %g' ~/.todo/"$LIST"/"$TODO_ITEM"
        echo -e "Item $TODO_ITEM marked as done in $LIST!"
        cat ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo -e "Item $TODO_ITEM not found in $LIST!"
        exit 1
    fi
}

todoundofunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        DONE_TODO_ITEM="$(cat ~/.todo/"$LIST"/"$TODO_ITEM")"
        DONE_TODO_ITEM="${DONE_TODO_ITEM:1}"
        sed -i 's%✘ %- %g' ~/.todo/"$LIST"/"$TODO_ITEM"
        echo -e "Item $TODO_ITEM marked as not done in $LIST!"
        cat ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo -e "Item $TODO_ITEM not found in $LIST!"
        exit 1
    fi
}

todormfunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    ITEM_CHECK="$(echo -e "$@" | cut -f3 -d" ")"
    if [ -z "$ITEM_CHECK" ]; then
        echo -e "Item input required!"
        echo
        helpfunc
        exit 1
    fi
    case $ITEM_CHECK in
        all)
            read -p "Remove all items in $LIST? Y/N " RMANSWER
            echo
            case $RMANSWER in
                y*|Y*)
                    rm -rf ~/.todo/"$LIST"
                    echo -e "All items in $LIST have been removed!"
                    ;;
                *)
                    echo -e "Items in $LIST were not removed."
                    ;;
            esac
            ;;
        *)
            TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
            if [ -z "$TODO_ITEM" ]; then
                echo -e "Item input required!"
                helpfunc
                exit 1
            fi
            if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                echo -e "Item $TODO_ITEM removed from $LIST!"
                cat ~/.todo/"$LIST"/"$TODO_ITEM"
                rm ~/.todo/"$LIST"/"$TODO_ITEM"
                if [ "$(dir ~/.todo/"$LIST" | wc -w)" = "0" ]; then
                    rm -r ~/.todo/"$LIST"
                else
                    for file in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n); do
                        if [ "$file" -gt "$TODO_ITEM" ]; then
                            FILE_NAME="$(($file-1))"
                            mv ~/.todo/"$LIST"/"$file" ~/.todo/"$LIST"/"$FILE_NAME"
                        fi
                    done
                fi
            else
                echo -e "Item $TODO_ITEM not found in $LIST!"
                exit 1
            fi
            ;;
    esac
}

todolistallfunc () {
    echo
    echo -e "$(tput bold)All todo lists$(tput sgr0):"
    echo
    for dir in $(dir ~/.todo); do
        echo -e "$(tput bold)$dir$(tput sgr0):"
        for file in $(dir -C -w 1 ~/.todo/"$dir" | sort -n); do
            echo -e "$file $(cat ~/.todo/"$dir"/"$file")"
        done
        echo
    done
}

todolistsinglefunc () {
    echo
    echo -e "$(tput bold)$LIST$(tput sgr0):"
    for file in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n); do
        echo -e "$file $(cat ~/.todo/"$LIST"/"$file")"
    done
    echo
}

todolistfunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ "$(dir ~/.todo | wc -w)" = "0" ]; then
        echo -e "No lists made yet!"
        echo
        helpfunc
        exit 1
    fi
    if [ -z "$LIST" ]; then
        todolistallfunc
    else
        if [ -d ~/.todo/"$LIST" ]; then
            todolistsinglefunc "$LIST"
        else
            echo -e "$LIST not found!"
            exit 1
        fi
    fi
}

if [ ! -d ~/.todo ]; then
    mkdir ~/.todo
fi

case $1 in
    add)
        todoaddfunc "$@"
        exit 0
        ;;
    edit)
        todoeditfunc "$@"
        exit 0
        ;;
    done)
        tododonefunc "$@"
        exit 0
        ;;
    undo)
        todoundofunc "$@"
        exit 0
        ;;
    rm)
        todormfunc "$@"
        exit 0
        ;;
    help|--help)
        helpfunc
        exit 0
        ;;
    *)
        todolistfunc "$@"
        exit 0
        ;;
esac
