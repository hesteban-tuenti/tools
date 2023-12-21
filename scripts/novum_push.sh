#!/usr/bin/env bash

FILES_TO_CHECKOUT=(acceptance/settings/android-toolium.cfg acceptance/settings/ios-toolium.cfg acceptance/features/e2e/app/novum/_setup/setup.feature acceptance/features/e2e/web/novum/_setup/setup.feature)

function get_branch() {
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Branch: $branch"
}

function remove_files_from_commit() {
    for file in "${FILES_TO_CHECKOUT[@]}"
    do
        git reset HEAD $file > /dev/null 2>&1
        git checkout -- $file 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Nothing to checkout in: $file"
            continue
        fi
    done
}

function commit_changed_files(){
    git add -u
    read -p "Commit message: " message
    git commit -m "$message"
}

function push_branch() {
    get_branch
    git push origin $branch
}

remove_files_from_commit
commit_changed_files
push_branch