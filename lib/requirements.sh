#!/bin/bash
#
# WP Requirements Module
# Author: Troy McGinnis
# Company: Gearbox
# Updated: March 10, 2018
#

wp::requirements() {
  local requirements; requirements=(wp)

  for i in "${requirements[@]}"; do
    cog::check_requirement "${i}"
  done
}