on adding folder items to this_folder after receiving these_items
    repeat with current_item in these_items
        try
            do shell script POSIX path of current_item & ".OnInsert"
        end try
    end repeat
end adding folder items to
