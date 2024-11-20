#!/usr/bin/env bash
WORDIR="<your_workdir>"

FILES_TO_KEEP=(
    "acceptance/settings/android-toolium.cfg"
    "acceptance/settings/ios-toolium.cfg"
    "acceptance/features/e2e/app/novum/_setup/setup.feature"
    "acceptance/features/e2e/web/novum/_setup/setup.feature"
    "acceptance/features/e2e/app/novum/_setup/har_setup.feature"
    "acceptance/features/e2e/app/novum/_setup/har_no_login_setup.feature"
    "acceptance/behave.ini"
    "acceptance/settings/logging.conf"
    "acceptance/resources/web_driver_agent"
    "acceptance/resources/users_data"
    )

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
    read -p "Commit message: " message
    git commit -m "$message"
}

function push_branch() {
    git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Upstream already set"
        git push
    else
        echo "Setting upstream to: $branch and pushing to origin"
        git push --set-upstream origin $branch
    fi
}


function check_pre_commit() {
    get_modified_files
    git add -u
    get_modified_files
    echo "Checking pre-commit hooks"
    pre-commit run
    if [ $? -eq 1 ]; then
        echo "Check pre-commit errors"
        exit 1
    fi
}

function check_features() {
    echo $1
    if [[ "${1}"  =~ "features" ]];then
        echo "pwd: $(pwd)"
        echo "Checking features"
        ./scripts/features.sh true
        if [ $? -eq 1 ]; then
        echo "Check features errors"
        exit 1
    fi
    fi
}

change_dir
check_features $1
get_branch
get_modified_files
get_staged_files
if [ $staged ]; then
    unstage_files_to_keep
fi
unstage_files_to_keep
checkout_files_to_keep
check_pre_commit
commit_changed_files
push_branch
