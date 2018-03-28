#!/bin/bash
#
# WP Defaults
# Author: Troy McGinnis
# Company: Gearbox
# Updated: March 27, 2018
#

wp::default::pages() {
  # Create pages
  wp post create --post_type=page --post_title='Home' --post_status=publish #--page_template='template-home.php'
  wp post create --post_type=page --post_title='Blog' --post_status=publish
  wp post create --post_type=page --post_title='Contact' --post_status=publish --page_template='template-contact.php'

  # Delete pages
  wp post delete 1 --force
  wp post delete 2 --force
}

wp::default::posts() {
  echo "Nothing to see here"
}

wp::default::menus() {
  # Menus
  message "Setting up menus..."
  wp menu create "Primary Navigation"
  wp menu location assign primary-navigation primary_navigation
  wp menu item add-post primary-navigation 3
  wp menu item add-post primary-navigation 4
  wp menu item add-post primary-navigation 2
  wp menu item add-post primary-navigation 5
}

wp::default::options() {
  # Options
  message "Setting up static pages..."
  wp option update page_on_front 3
  wp option update show_on_front page
  wp option update page_for_posts 4
  wp option update permalink_structure "/%postname%/"
  wp rewrite flush --hard

  message "General setup stuff..."
  wp option update timezone_string America/Vancouver
}

wp::default::install() {
  wp::default::pages
  # wp::default::posts
  wp::default::menus
  wp::default::options
}

#
# Lib main
# --------------------------------------------------

wp::default::main() {
  case "$1" in
    install)
      wp::default::install "${@:2}"
      ;;
    pages)
      wp::default::pages "${@:2}"
      ;;
    posts)
      wp::default::posts "${@:2}"
      ;;
    menus)
      wp::default::menus "${@:2}"
      ;;
    options)
      wp::default::options "${@:2}"
      ;;
    *)
      usage "cog wp default" "install"
      cog::exit
  esac
}