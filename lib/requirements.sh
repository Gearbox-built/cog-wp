#!/bin/bash
#
# WP Requirements Module
# Author: Troy McGinnis
# Company: Gearbox
# Updated: August 4, 2017
#

wp::requirements() {
  local requirements; requirements=(wp composer)

  for i in "${requirements[@]}"; do
    cog::check_requirement "${i}"
  done
}