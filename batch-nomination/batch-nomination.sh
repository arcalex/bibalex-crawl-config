#!/bin/sh

# Copyright (C) 2013 Bibliotheca Alexandrina <www.bibalex.org>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# By Mahmoud Mubarak, Youssef Eldakar (editing)

nomination_url=$1
common_fields=$2
clusters=$3

# Assume default-surt.sh is located right next to this script.
default_surt=$(dirname $0)/default-surt.sh

# Get csrftoken from nomination_url.
csrftoken=$(curl $nomination_url 2>/dev/null | sed -n "/csrfmiddlewaretoken/s/.*value='\([^']*\)'.*/\1/;T;p")

for cluster in $clusters/*; do
  while read seed; do
    echo curl $(cat $common_fields) $(cat $cluster/fields) -d url_value="$seed" -d Comment="'SURT: +$(echo $seed | $default_surt)'" -d csrfmiddlewaretoken=$csrftoken --cookie csrftoken=$csrftoken $nomination_url
  done < $cluster/seeds
done
