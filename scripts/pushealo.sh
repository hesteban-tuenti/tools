#!/usr/bin/env bash
WORDIR=/Users/path_to_your_workdir

FILES_TO_KEEP=(acceptance/settings/android-toolium.cfg acceptance/settings/ios-toolium.cfg acceptance/features/e2e/app/novum/_setup/setup.feature acceptance/features/e2e/web/novum/_setup/setup.feature)

function change_dir() {
    cd $WORDIR/novum-tests
}

function get_branch() {
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Branch: $branch"
}

function get_staged_files() {
    FILES_STAGED=($(git diff --cached --name-only))
    echo "Staged files: ${FILES_STAGED[@]}"
}

function get_modified_files() {
    FILES_MODIFIED=($(git status --porcelain | grep '^ M' | awk '{print $2}'))
    echo "Modified files: ${FILES_MODIFIED[@]}"
}

function unstage_files_to_keep() {
    for file in "${FILES_STAGED[@]}"
    do
        echo "File: $file"
        if [[ " ${FILES_TO_KEEP[@]} " =~ " ${file} " ]]; then
            echo "Removing from stage file: $file"
            git reset HEAD $file > /dev/null 2>&1
        fi
    done
}

function checkout_files_to_keep() {
    for file in "${FILES_MODIFIED[@]}"
    do
        echo "File: $file"
        if [[ " ${FILES_TO_KEEP[@]} " =~ " ${file} " ]]; then
            echo "Checking out file: $file"
            git checkout -- $file 2>/dev/null
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

change_dir
get_modified_files
get_staged_files
unstage_files_to_keep
checkout_files_to_keep
commit_changed_files
push_branch