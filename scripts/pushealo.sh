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
    if [ ${#FILES_STAGED[@]} -eq 0 ]; then
        echo "No files staged"
        staged=false
    else
        staged=true
        echo "Staged files:"
        for file in "${FILES_STAGED[@]}"
        do
            echo "  - $file"
        done
    fi
}

function get_modified_files() {
    FILES_MODIFIED=($(git status --porcelain | grep '^ M' | awk '{print $2}'))
    echo "Modified files:"
    for file in "${FILES_MODIFIED[@]}"
    do
        echo "  - $file"
    done
}

function unstage_files_to_keep() {
    for file in "${FILES_STAGED[@]}"
    do
        if [[ " ${FILES_TO_KEEP[@]} " =~ " ${file} " ]]; then
            echo "Removing from stage file: $file"
            git reset HEAD $file > /dev/null 2>&1
        fi
    done
}

function checkout_files_to_keep() {
    for file in "${FILES_MODIFIED[@]}"
    do
        if [[ " ${FILES_TO_KEEP[@]} " =~ " ${file} " ]]; then
            echo "Checking out: $file"
            git checkout -- $file 2>/dev/null
        fi
    done
}

function commit_changed_files(){
    echo "Committing changes"
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
if [ $staged ]; then
    unstage_files_to_keep
fi
unstage_files_to_keep
checkout_files_to_keep
commit_changed_files
push_branch