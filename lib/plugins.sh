#!/bin/bash
#
# WP Plugins Lib
# Author: Troy McGinnis
# Company: Gearbox
# Updated: April 8, 2018
#

wp::plugins::download() {
  # [$dir]
  cog::params "$@" --optional="dir"
  local plugin_dir; plugin_dir=${dir:-$( pwd )}

  cd "$plugin_dir" || exit

  message "Downloading Premium Plugins"

  # Grab from git repo
  git clone "$WP_PLUGIN_REPO" plugin-tmp
  mv plugin-tmp/* .
  rm -rf plugin-tmp/

  cd -  > /dev/null || exit
}

wp::plugins::install() {
  # [$dir]
  cog::params "$@" --optional="dir"
  local plugin_dir; plugin_dir=${dir:-$( pwd )}

  cd "$plugin_dir" || exit

  message "Installing All Plugins"

  wp::plugins::download "$@"
  wp plugin install $WP_PLUGINS_ACTIVATE
  wp plugin activate $WP_PLUGINS_ACTIVATE

  cd -  > /dev/null || exit
}


#
# Lib main
# --------------------------------------------------

wp::plugins::main() {
  case "$1" in
    install)
      wp::plugins::install "${@:2}"
      ;;
    download)
      wp::plugins::download "${@:2}"
      ;;
    *)
      usage "cog wp plugins" "install,download"
      cog::exit
  esac
}