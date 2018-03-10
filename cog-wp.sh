#!/bin/bash
#
# Cog WordPress Module
# Author: Troy McGinnis
# Company: Gearbox
# Updated: March 9, 2018
#
#
# HISTORY:
#
# * 2018-03-09 - v0.0.1 - First Creation
#
# ##################################################
#
if [[ ! "${#BASH_SOURCE[@]}" -gt 0 ]] || [[ "${BASH_SOURCE[${#BASH_SOURCE[@]}-1]##*/}" != 'cog.sh' ]]; then
  echo 'Module must be executed through cog.'
  return || exit
fi
#
cog::source_lib "${BASH_SOURCE[0]}"
#

# WordPress Install
# Downloads and installs a fresh WP instance
#
wp::wp_install() {
  for i in "$@"
  do
    case $i in
      --name=*)
        local name="${i#*=}"
        ;;
      --dir=*)
        local dir="${i#*=}"
        ;;
      --db=*)
        local db="${i#*=}"
        ;;
      --db-user=*)
        local db_user="${i#*=}"
        ;;
      --db-pass=*)
        local db_pass="${i#*=}"
        ;;
    esac
  done

  if [[ $# -lt 1 ]] || [[ -z "$name" ]]; then
    local sub="install --local --name=<name>|--db=<db> [--db-user=<db-user>] [--db-pass=<db-pass>] [--db-host=<db-host>]"
    sub="${sub},config --db=<db> --db-user=<db-user> --db-pass=<db-pass> [--db-host=<db-host>]"
    usage "cog wp" "install, --name=<name>,[--dir=<dir>],[--db=<db>],[--db-user=<db-user>],[--db-pass=<db-pass>]" "arg"
    cog::exit
  fi

  local dir; dir=${dir:-$( pwd )}
  local db; db=${db:-$name}
  local db_user; db_user="${db_user:-root}"
  local db_pass; db_pass="${db_pass:-root}"

  cd "$dir" || exit

  message "Installing WP..."
  wp core download
  wp config create --dbname="$name" --dbuser="$db_user" --dbpass="$db_pass"

  cd - > /dev/null || exit
}

# WordPress Setup
# Downloads, installs, and setups up a fresh WP instance
#
wp::wp_setup() {
  message "Setting up WP..!"
  # 1. wp::wp_install
  # 2. wp db create
  # 3. wp core install
}

# Update Salts
# Creates new salts and updates the provided or default file
#
# @arg optional --file File that contains salts to be updated (default: wp-config.php)
#
wp::update_salts() {
  if [[ $# -ge 1 ]]; then
    for i in "$@"
    do
      case $i in
        --file=*)
          local salt_file="${i#*=}"
          ;;
      esac
    done
  fi

  local salt; local key
  local salt_file=${salt_file:-wp-config.php}

  message "Generating New Keys/Salts..."

  if [[ -f "$salt_file" ]]; then
    for salt in $WP_SALTS; do
      key=$(util::random_key)
      perl -pi -e "s/${salt}=.*/${salt}='${key}'/g" "$salt_file" # dotenv
      perl -pi -e "s/(\'${salt}\'\,.*)(\'.*\')\)/\1'${key}')/g" "$salt_file"
    done
  else
    error "Cannot find file '$salt_file'."
  fi
}

# Check WP CLI
# Checks that WP CLI is up to date
#
# @arg optional --file File that contains salts to be updated (default: wp-config.php)
#
wp::check_wp_cli() {
  # WP CLI at latest?
  WP_CLI="$(wp cli check-update --format=count)"

  if [[ -n $WP_CLI ]]; then
    warning "WP CLI is ${RED}out of date${NC}. We recommend you update WP CLI before continuing - things often break when not on the latest version"

    echo "Press any key to continue."
    read -n1 -sr
  fi
}

wp::bootstrap() {
  message "Gearboxify."

  # 1. Install theme
  # 2. Install defaults
  # 3. Install plugins
}


#
# Module main
# --------------------------------------------------

wp::main() {
  # TODO: Update .env PROD_USER, PROD_WP_HOME PROD_DB_NAME, PROD_DB_USER, PROD_DB_PASS
  wp::requirements
  local module; module=$( basename "$( dirname "${BASH_SOURCE[0]}")")

  case "$1" in
    install)
      wp::wp_install "${@:2}"
      ;;
    setup)
      wp::wp_setup "${@:2}"
      ;;
    salt|salts)
      wp::update_salts "${@:2}"
      ;;
    bootstrap)
      wp::bootstrap "${@:2}"
      ;;
    *)
      local lib; lib="${module}::${1}::main"

      if [[ $(type -t "$lib") == 'function' ]]; then
        "$lib" "${@:2}"
        cog::exit
      else
        usage "cog wp" "install,setup,salts,bootstrap"
        cog::exit
      fi
      ;;
  esac
}