#!/bin/bash
#
# Cog WordPress Module
# Author: Troy McGinnis
# Company: Gearbox
# Updated: March 27, 2018
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
wp::install() {
  cog::params "$@" --optional="dir db db-user db-pass" --required="name"

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
wp::setup() {
  cog::params "$@" --optional="title dir db db-user db-pass admin-email admin-user" --required="name url"

  local title; title="${title:-$name}"
  local admin_email; admin_email="${admin_email:-$WP_ADMIN_EMAIL}"
  local admin_user; admin_user="${admin_user:-$WP_ADMIN_USER}"

  wp::install "$@"
  wp db create
  wp core install --url="$url" --title="$title" --admin_user="$admin_user" --admin_email="$admin_email"
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

# WP Silence
# Creates new //Silence is golden index file
#
# @arg optional --dir Directory to create the index file (default: pwd)
#
wp::silence() {
  cog::params "$@" --optional="dir"
  local dir; dir=${dir:-$( pwd )}
  local index; index="${dir}/index.php"

  if [[ -f "$index" ]]; then
    error "Index file already exists."
    cog::exit
  fi

  message "Silence is golden..."

  (
  echo '<?php'
  echo '// Silence is golden.'
  ) > "$index"
}

wp::bootstrap() {
  cog::params "$@" --optional="title dir db db-user db-pass" --required="name url"
  local dir; dir=${dir:-$( pwd )}

  header "Gearboxify."

  wp::setup "$@"
  wp::plugins::install --dir="${dir}/wp-content/plugins"
  # 1. Install theme
  # 2. Install defaults
  # 3. Install plugins
}


#
# Module main
# --------------------------------------------------

wp::main() {
  wp::requirements
  local module; module=$( basename "$( dirname "${BASH_SOURCE[0]}")")

  case "$1" in
    install)
      wp::install "${@:2}"
      ;;
    setup)
      wp::setup "${@:2}"
      ;;
    salt|salts)
      wp::update_salts "${@:2}"
      ;;
    bootstrap)
      wp::bootstrap "${@:2}"
      ;;
    silence)
      wp::silence "${@:2}"
      ;;
    *)
      local lib; lib="${module//cog-}::${1}::main"

      if [[ $(type -t "$lib") == 'function' ]]; then
        "$lib" "${@:2}"
        cog::exit
      else
        libs
        usage "cog wp" "install,setup,salts,theme,plugins,bootstrap"
        cog::exit
      fi
      ;;
  esac
}