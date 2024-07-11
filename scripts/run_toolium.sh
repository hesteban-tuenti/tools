#!/usr/bin/env bash
WORDIR="<your_workdir>"
BRANDS=(moves o2uk vivobr o2es o2de blaude)
PLATFORMS=(android ios webapp)
EXECUTION_TYPE=(HAR BER)
ID="<your_user_id>"
PASS="<your_pass>"

declare -A APP_TITLES=(
    ["moves_android"]="Android Mi Movistar España internal enterprise"
    ["moves_ios"]="iOS Mi Movistar España Enterprise Debuggable internal"
    ["o2uk_android"]="Android MyO2 UK Enterprise CERT0 internal"
    ["o2uk_ios"]="iOS MyO2 UK Enterprise Debuggable internal"
    ["vivobr_android"]="Android Internal Meu Vivo Movel Enterprise"
    ["vivobr_ios"]="iOS Meu Vivo Movel Enterprise Debuggable internal"
    ["blaude_android"]="Android Internal Blau DE Enterprise"
    ["blaude_ios"]="iOS Blau DE Enterprise Debuggable internal"
)

function change_dir() {
    cd $WORDIR/novum-tests/acceptance
}

function set_pythonpath() {
    export PYTHONPATH=$WORDIR/novum-tests
}

function show_help() {
  echo "  usage: run-toolium -f <runner> [-t <execution_type>]"
  exit 1
}

function parse_args() {
  while [ $# -ne 0 ]; do
    case $1 in
      -h|--help)
        show_help
        ;;
      -f|--runner)
        shift
        runner=`echo "$1" | sed 's|acceptance/||' `
        ;;
      -t|--type)
        shift
        execution_type="$1"
        ;;
      *)
        other_args+=("$1")
        ;;
    esac
    shift
  done
  if [ -z "$runner" ] ; then
    echo "Please set the runner as param with: -f or --runner"
    show_help
    exit 1
  fi
}

function is_webapp() {
    if [[ $runner =~ "webapp" ]]; then
        is_webapp=0 
    else
        is_webapp=1
    fi
}


function validate_brand() {
    for brand in "${BRANDS[@]}"
    do
      result_brand=`echo $runner | sed -n "/\/$brand\//p" `
      if [ -n "$result_brand" ] ; then
              return 0
      fi
    done
    echo "No valid brand found in the runner" 
    echo "  Valid brands: "${BRANDS[@]}""
    exit 1
}

function validate_platform() {
    for platform in "${PLATFORMS[@]}"
    do
    result=`echo $runner | sed -n "/\/$platform-*./p" `
    if [ -n "$result" ] && [ $is_webapp -eq 1 ]; then
            command_platform="-D toolium_env=$platform"
            return 0
    elif [ -n "$result" ] && [ $is_webapp -eq 0 ]; then
            command_platform="-D toolium_env=webapp_local"
            return 0
    fi
    done
    echo "No valid platform found in the runner"
    echo echo "Valid platforms: ${PLATFORMS[@]}"
    exit 1
}

function validate_execution_type() {
    if [[ ! " ${EXECUTION_TYPE[@]} " =~ " ${1} " ]]; then
        echo "$1 is not a valid execution type"
        echo "Valid execution types: ${EXECUTION_TYPE[@]}"
        exit 1
    else
        get_version_from_jira $1
        validate_versions $1
    fi
}   

function get_version_from_jira() {

    regex_app="^[0-9]{1,2}\.[0-9]{1,2}$"
    regex_back="^[0-9]{6}(-b)?$"
    
    if [ -z "$PASS" ]; then
      read -s -p "Enter your pass: " PASS
      echo "\n" 
    fi

    my_array=($( curl -s -u $ID:$PASS "https://jira.tid.es/rest/api/2/project/QANOV/versions"| \
            jq -r '.[].name'))
    if [ -z "$my_array" ]; then
        echo "Cannot retrieve the versions from JIRA: Check your credentials"
        exit 1
    fi
    len=${#my_array[@]}
    app_release_versions=()
    back_release_versions=()
    for version in "${my_array[@]}"; do
        if [[ $version =~ $regex_app ]]; then
            app_release_versions+=("$version")
        fi
        if [[ $version =~ $regex_back ]]; then
            back_release_versions+=("$version")
        fi
    done

    if [[ "${1}"  =~ "HAR" ]];then
      APP_VERSION=${app_release_versions[${#app_release_versions[@]}-1]}
      BER_VERSION=""
      JIRA_VERSION=$APP_VERSION

    else
      APP_VERSION=${app_release_versions[${#app_release_versions[@]}-2]}
      BER_VERSION=${back_release_versions[${#back_release_versions[@]}-1]}
      JIRA_VERSION=$BER_VERSION
    fi
}

function validate_versions() {
    read -p "Is it the correct JIRA version?: $JIRA_VERSION (y/n) " answer
    case ${answer:0:1} in
        n|N )
            read -p "Enter the version: " JIRA_VERSION
            ;;
        * )
        ;;
    esac
    command_execution_type="-D Jira_enabled=true -D JiraExecution_version=$JIRA_VERSION -D Jira_release_type=$1"

    if [[ "${1}"  =~ "BER" ]] && [ $is_webapp -eq 1 ];then
      read -p "Is this the correct build version?: $APP_VERSION (y/n) " answer
      case ${answer:0:1} in
        n|N )
            read -p "Enter the build version: " APP_VERSION
            ;;
        * )
        ;;
      esac
      command_execution_type+=" -D Appcenter_app_build=short_version:$APP_VERSION"
    fi
  echo "Command execution type: $command_execution_type"
}

function get_app(){
  if [ $is_webapp -eq 1 ]; then
    key="${1}_${2}"
    command_app="-D 'Appcenter_app_title=${APP_TITLES[$key]}'"
  fi
}

function launch_toolium() {
    # input user for confirmation to launch toolium
    echo -e "Execution with parameters: \nRunner: $runner\nBrand: $brand\nPlatform: $platform\nExecution Type: $execution_type\nVersion: $VERSION"
    read -p "Are you sure to launch toolium? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            echo "Launching toolium..."
            eval  "toolium behave-runner -j -f $runner $command_platform $command_app $command_execution_type"
            ;;
        * )
            echo "Exiting..."
            exit 1
            ;;
    esac
}

change_dir
set_pythonpath
parse_args "$@"
is_webapp
validate_brand
validate_platform
if [ -n "$execution_type" ]; then
    validate_execution_type $execution_type
fi
get_app $brand $platform
launch_toolium
