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
    todo add list i=n item      # Adds item to specified list with importance level n (4-0)
    todo edit list n            # Opens the default editor to edit item n in specified list
    todo edit list n i=n        # Changes the importance level for item n to importance level n
    todo done list n|all        # Marks item n or all items in specified list with an X
    todo undo list n|all        # Removes X from item n or all items in specified list
    todo mv list n n|list2      # Moves item n from list to n|list2
    todo mv list list2          # Moves all items from list to list2
    todo rm list n|all          # Removes n|all from list

Examples:
    todo                        # Lists all items in all todo lists
    todo mylist                 # Lists all items in mylist
    todo add mylist my item     # Adds my item to mylist
    todo add mylist i=4 item    # Adds item to mylist with importance level 4
    todo done mylist 1          # Marks item 1 in mylist with an X
    todo done mylist all        # Marks all items in mylist with an X
    todo undo mylist 1          # Removes X from item 1 in mylist
    todo undo mylist all        # Removes X from all items in mylist
    todo edit mylist 1          # Opens the default editor to edit item 1 in mylist
    todo edit mylist 1 i=4      # Change the importance level for item 1 in mylist to level 4
    todo mv mylist 1 2          # Moves item 1 from mylist to position 2
    todo mv mylist 1 mylist2    # Moves item 1 from mylist to mylist2
    todo mv mylist mylist2      # Moves all items from mylist to mylist2
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
    if echo -e "$@" | cut -f4 -d" " | grep -q '='; then
        IMPORTANT_LEVEL="$(echo -e "$@" | cut -f2 -d"=" | cut -f1 -d" ")"
        TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
        if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
            case $IMPORTANT_LEVEL in
                4)
                    sed -i 's%- \x1b\[[0-9;]*m%- \x1b\[31m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    sed -i 's%✘ \x1b\[[0-9;]*m%✘ \x1b\[31m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    echo -e "Item \"$TODO_ITEM\" in $LIST changed to importance level 4!"
                    ;;
                3)
                    sed -i 's%- \x1b\[[0-9;]*m%- \x1b\[33m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    sed -i 's%✘ \x1b\[[0-9;]*m%✘ \x1b\[33m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    echo -e "Item \"$TODO_ITEM\" in $LIST changed to importance level 3!"
                    ;;
                2)
                    sed -i 's%- \x1b\[[0-9;]*m%- \x1b\[32m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    sed -i 's%✘ \x1b\[[0-9;]*m%✘ \x1b\[32m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    echo -e "Item \"$TODO_ITEM\" in $LIST changed to importance level 2!"
                    ;;
                0)
                    sed -i 's%- \x1b\[[0-9;]*m%- \x1b\[90m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    sed -i 's%✘ \x1b\[[0-9;]*m%✘ \x1b\[90m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    echo -e "Item \"$TODO_ITEM\" in $LIST changed to importance level 0!"
                    ;;
                *)
                    sed -i 's%- \x1b\[[0-9;]*m%- \x1b\[39m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    sed -i 's%✘ \x1b\[[0-9;]*m%✘ \x1b\[39m%g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    echo -e "Item \"$TODO_ITEM\" in $LIST changed to importance level 1!"
                    ;;
            esac
        else
            echo -e "Item $TODO_ITEM not found in $LIST!"
            exit 1
        fi
    else
        TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
        if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
            $EDITOR ~/.todo/"$LIST"/"$TODO_ITEM"
        else
            echo -e "Item $TODO_ITEM not found in $LIST!"
            exit 1
        fi
    fi
}

tododonefunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
    case $TODO_ITEM in
        all)
            echo "Marking all items in $LIST as done..."
            for TODO_ITEM in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n); do
                if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                    sed -i 's%- %✘ %g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    cat ~/.todo/"$LIST"/"$TODO_ITEM"
                else
                    echo -e "Item $TODO_ITEM not found in $LIST!"
                    exit 1
                fi
            done
            ;;
        *)
            if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                sed -i 's%- %✘ %g' ~/.todo/"$LIST"/"$TODO_ITEM"
                echo -e "Item $TODO_ITEM marked as done in $LIST!"
                cat ~/.todo/"$LIST"/"$TODO_ITEM"
            else
                echo -e "Item $TODO_ITEM not found in $LIST!"
                exit 1
            fi
            ;;
    esac
}

todoundofunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    fi
    TODO_ITEM="$(echo -e "$@" | cut -f3 -d" ")"
    case $TODO_ITEM in
        all)
            echo "Marking all items in $LIST as not done..."
            for TODO_ITEM in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n); do
                if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                    sed -i 's%✘ %- %g' ~/.todo/"$LIST"/"$TODO_ITEM"
                    cat ~/.todo/"$LIST"/"$TODO_ITEM"
                else
                    echo -e "Item $TODO_ITEM not found in $LIST!"
                    exit 1
                fi
            done
            ;;
        *)
            if [ -f ~/.todo/"$LIST"/"$TODO_ITEM" ]; then
                sed -i 's%✘ %- %g' ~/.todo/"$LIST"/"$TODO_ITEM"
                echo -e "Item $TODO_ITEM marked as not done in $LIST!"
                cat ~/.todo/"$LIST"/"$TODO_ITEM"
            else
                echo -e "Item $TODO_ITEM not found in $LIST!"
                exit 1
            fi
            ;;
    esac
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

todomvfunc () {
    LIST="$(echo -e "$@" | cut -f2 -d" ")"
    if [ -z "$LIST" ]; then
        helpfunc
        exit 1
    elif [ ! -d ~/.todo/"$LIST" ]; then
        echo "$LIST does not exist!"
        exit 1
    fi
    TODO_ITEM_1="$(echo -e "$@" | cut -f3 -d" ")"
    TODO_ITEM_2="$(echo -e "$@" | cut -f4 -d" ")"
    case $TODO_ITEM_1 in
        1*|2*|3*|4*|5*|6*|7*|8*|9*)
            case $TODO_ITEM_2 in
                1*|2*|3*|4*|5*|6*|7*|8*|9*)
                    if [ ! -f ~/.todo/"$LIST"/"$TODO_ITEM_1" ] || [ ! -f ~/.todo/"$LIST"/"$TODO_ITEM_2" ]; then
                        echo "Items $TODO_ITEM_1 and/or $TODO_ITEM_2 not found in $LIST!"
                        exit 1
                    fi
                    mv ~/.todo/"$LIST"/"$TODO_ITEM_1" ~/.todo/"$LIST"/"$TODO_ITEM_1"-temp
                    mv ~/.todo/"$LIST"/"$TODO_ITEM_2" ~/.todo/"$LIST"/"$TODO_ITEM_1"
                    mv ~/.todo/"$LIST"/"$TODO_ITEM_1"-temp ~/.todo/"$LIST"/"$TODO_ITEM_2"
                    echo "Item $TODO_ITEM_1 moved to position $TODO_ITEM_2 in $LIST!"
                    ;;
                *)
                    LIST_2="$TODO_ITEM_2"
                    if [ ! -f ~/.todo/"$LIST"/"$TODO_ITEM_1" ]; then
                        echo "Item $TODO_ITEM_1 not found in $LIST!"
                        exit 1
                    fi
                    if [ ! -d ~/.todo/"$LIST_2" ]; then
                        mkdir ~/.todo/"$LIST_2"
                    fi
                    FILE_NAME="$(($(dir ~/.todo/"$LIST_2" | wc -w)+1))"
                    mv ~/.todo/"$LIST"/"$TODO_ITEM_1" ~/.todo/"$LIST_2"/"$FILE_NAME"
                    echo "Item $TODO_ITEM_1 has been moved from $LIST to $LIST_2!"
                    if [ "$(dir ~/.todo/"$LIST" | wc -w)" = "0" ]; then
                        rm -r ~/.todo/"$LIST"
                    else
                        for file in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n); do
                            if [ "$file" -gt "$TODO_ITEM_1" ]; then
                                FILE_NAME="$(($file-1))"
                                mv ~/.todo/"$LIST"/"$file" ~/.todo/"$LIST"/"$FILE_NAME"
                            fi
                        done
                    fi
                    ;;
            esac
            ;;
        *)
            LIST_2="$TODO_ITEM_1"
            if [ ! -d ~/.todo/"$LIST_2" ]; then
                mkdir ~/.todo/"$LIST_2"
            fi
            for item in $(dir -C -w 1 ~/.todo/"$LIST" | sort -n);do
                FILE_NAME="$(($(dir ~/.todo/"$LIST_2" | wc -w)+1))"
                mv ~/.todo/"$LIST"/"$item" ~/.todo/"$LIST_2"/"$FILE_NAME"
            done
            echo "All items in $LIST moved to $LIST_2!"
            rm -r ~/.todo/"$LIST"
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
    mv)
        todomvfunc "$@"
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
