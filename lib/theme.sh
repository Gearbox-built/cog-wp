#!/bin/bash
#
# WP Theme Lib
# Author: Troy McGinnis
# Company: Gearbox
# Updated: March 10, 2018
#

wp::theme::download() {
  echo "Nothing to see here"
  # 1. Download theme from specified URL or default from .config
}

wp::theme::install() {
  for i in "$@"
  do
    case $i in
      --arg1=*)
        local arg1="${i#*=}"
        ;;
      --arg2=*)
        local arg2="${i#*=}"
        ;;
    esac
  done

  if [[ $# -lt 1 || -z "$arg1" ]]; then
    usage "cog sample sample-lib" "lib-task, --arg1=<arg1>,[--arg2=<arg2>]" "arg"
    cog::exit
  fi

  echo "More lib"
  echo "Arg #1: $arg1"
  echo "Arg #2: $arg2"
}

#
# Lib main
# --------------------------------------------------

wp::theme::main() {
  case "$1" in
    install)
      server::lib_task "${@:2}"
      ;;
    *)
      usage "cog wp theme" "install"
      cog::exit
  esac
}