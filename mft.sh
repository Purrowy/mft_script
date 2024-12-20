#!/bin/bash

# basic settings
days_notify=2
days_delete=14
delete_olds_bool=true

# list of paths to check + assigned email addresses
declare -A paths_emails
paths_emails["/home/purr/test/customerAAA/tocust"]="AAA@ps.com"
paths_emails["/home/purr/test/customerBBB/tocust"]="BBB@ps.com"

# main function with basic logic for the script
main() {

    for path in "${!paths_emails[@]}"; do
        if check_date "$path" "$days_notify"; then
            echo "found olds in $path"
            send_email "$path" "${paths_emails[$path]}"
        fi
    done

    if $delete_olds_bool; then
        for path in "${!paths_emails[@]}"; do
            if check_date "$path" "$days_delete"; then
            delete_files "$path" "$days_delete"
            fi
        done
    fi    
}

# return true if any file on path: $1 is older than number of days: $2
check_date() {
    local old_files=$(find $1 -type f -mtime +$2 | wc -l)
    [ "$old_files" -gt 0 ]
}

# send a message about path: $1 to address: $2 and add info to log file
send_email() {
    echo -e "Dear...\nFiles stuck on $1\nPls check" # | mail sendmail or whatever works...
    echo "Email sent to $2 on $(date '+%Y-%m-%d %H:%M')" >> email_log.txt
}

# add info about deleted files from path: $1 to log file and then delete them. $2 decides how old the timestamp must be for files to be deleted
delete_files() {
    echo -e "Deleting:\n$(find $1 -type f -mtime +$2)\nTimestamp: $(date '+%Y-%m-%d %H:%M')\n---" >> delete_log.txt
    find $1 -type f -mtime +$2 -print #-delete
}

main