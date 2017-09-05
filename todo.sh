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
    todo edit list item#        # Opens the default editor to edit specified list item#
    todo done list item#        # Marks an item# in list or specified list with an X to indicate it is done
    todo undo list item#        # Removes X from specified item# in list to mark it as not done
    todo rm list item#          # Removes item# from list

Examples:
    todo                        # Lists all items in all todo lists
    todo mylist                 # Lists all items in mylist
    todo add mylist my item     # Adds my item to mylist
    todo done mylist 1          # Marks item 1 in mylist with an X to indicate it is done
    todo undo mylist 1          # Removes X from item 1 in mylist to mark it as not done
    todo edit mylist 1          # Opens the default editor to edit item 1 in mylist
    todo rm mylist 1            # Removes item 1 from mylist
    todo rm mylist all          # Removes all items from mylist
"
}

todoaddfunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
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
    TODO_ITEM="$(echo "$@" | cut -f3- -d" ")"
    if [ -z "$TODO_ITEM" ]; then
        echo "Item input required!"
        echo
        helpfunc
        exit 1
    fi
    echo "- $TODO_ITEM" > ~/.todo/"$LIST"/"$FILE_NAME"
    echo "Item \"$TODO_ITEM\" added to $LIST list!"
}

todoeditfunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        $EDITOR ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo "Item $TODO_ITEM not found in $LIST!"
        echo
        helpfunc
        exit 1
    fi
}

tododonefunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        DONE_TODO_ITEM="$(cat ~/.todo/"$LIST"/"$TODO_ITEM")"
        DONE_TODO_ITEM="${DONE_TODO_ITEM:1}"
        sed -i s:-"$DONE_TODO_ITEM":✘"$DONE_TODO_ITEM":g ~/.todo/"$LIST"/"$TODO_ITEM"
        echo "Item $TODO_ITEM marked as done in $LIST!"
        cat ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo "Item $TODO_ITEM not found in $LIST!"
        echo
        helpfunc
        exit 1
    fi
}

todoundofunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo "$@" | cut -f3 -d" ")"
    if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
        DONE_TODO_ITEM="$(cat ~/.todo/"$LIST"/"$TODO_ITEM")"
        DONE_TODO_ITEM="${DONE_TODO_ITEM:1}"
        sed -i s:✘"$DONE_TODO_ITEM":-"$DONE_TODO_ITEM":g ~/.todo/"$LIST"/"$TODO_ITEM"
        echo "Item $TODO_ITEM marked as not done in $LIST!"
        cat ~/.todo/"$LIST"/"$TODO_ITEM"
    else
        echo "Item $TODO_ITEM not found in $LIST!"
        echo
        helpfunc
        exit 1
    fi
}

todormfunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    ITEM_CHECK="$(echo "$@" | cut -f3 -d" ")"
    if [ -z "$ITEM_CHECK" ]; then
        echo "Item input required!"
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
                    echo "All items in $LIST have been removed!"
                    ;;
                *)
                    echo "Items in $LIST were not removed."
                    ;;
            esac
            ;;
        *)
            TODO_ITEM="$(echo "$@" | cut -f3 -d" ")"
            if [ -z "$TODO_ITEM" ]; then
                echo "Item input required!"
                helpfunc
                exit 1
            fi
            if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                echo "Item $TODO_ITEM removed from $LIST!"
                cat ~/.todo/"$LIST"/"$TODO_ITEM"
                rm ~/.todo/"$LIST"/"$TODO_ITEM"
            else
                echo "Item $TODO_ITEM not found in $LIST!"
                echo
                helpfunc
                exit 1
            fi
            ;;
    esac
}

todolistallfunc () {
    echo
    echo "$(tput bold)All todo lists$(tput sgr0):"
    echo
    for dir in $(dir ~/.todo); do
        echo "$(tput bold)$dir$(tput sgr0):"
        for file in $(dir ~/.todo/$dir); do
            echo "$file $(cat ~/.todo/"$dir"/"$file")"
        done
        echo
    done
}

todolistsinglefunc () {
    echo
    echo "$(tput bold)$LIST$(tput sgr0):"
    for file in $(dir ~/.todo/"$LIST"); do
        echo "$file $(cat ~/.todo/"$LIST"/"$file")"
    done
    echo
}

todolistfunc () {
    LIST="$(echo "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        if [ "$(dir ~/.todo | wc -w)" = "0" ]; then
            echo "No lists made yet!"
            echo
            helpfunc
            exit 1
        fi
        todolistallfunc
    else
        if [ -d ~/.todo/"$LIST" ]; then
            todolistsinglefunc "$LIST"
        else
            echo "$LIST not found!"
            echo
            helpfunc
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
    help)
        helpfunc
        exit 0
        ;;
    *)
        todolistfunc "$@"
        exit 0
        ;;
esac
