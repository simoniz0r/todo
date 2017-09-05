# todo
A simple scripts that manages todo lists in ~/.todo

Usage: todo [OPTION] [ITEM]

todo manages todo lists in an easy to use manner.  Lists are stored in ~/.todo/ListName
with each item in the list stored as a separate file in that directory.

Options:
- todo                        # Lists all lists or items in specified list    
- todo add list item          # Adds item to specified list
- todo edit list item#        # Opens the default editor to edit specified list item#
- todo done list item#        # Marks an item# in list or specified list with an X to indicate it is done
- todo undo list item#        # Removes X from specified item# in list to mark it as not done
- todo rm list item#          # Removes item# from list

Examples:
- todo                        # Lists all items in all todo lists
- todo mylist                 # Lists all items in mylist
- todo add mylist my item     # Adds my item to mylist
- todo done mylist 1          # Marks item 1 in mylist with an X to indicate it is done
- todo undo mylist 1          # Removes X from item 1 in mylist to mark it as not done
- todo edit mylist 1          # Opens the default editor to edit item 1 in mylist
- todo rm mylist 1            # Removes item 1 from mylist
- todo rm mylist all          # Removes all items from mylist
    
