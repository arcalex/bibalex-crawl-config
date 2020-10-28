#!/bin/sh
set -x
set -e

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

# By Mohamed Elsayed, Youssef Eldakar (editing)

# This script has last been verified to work as intended with the
# following commit:
#
# 829693b6d43f40b1b045f08611a4fa5e27395e29
#
# Beyond that point in time, adjustments may be required.

# This script requires sufficient privileges to install packages
# (apt-get), manage services, and write to the following paths:
#
# /etc/default/tomcat7
# /etc/authbind/byport/
#
# /var/lib/tomcat7/webapps/
# /var/local/

# Set option defaults.
tmpdir=/tmp
branding=branding
files=files

# Install packages.
apt-get -y install openjdk-7-jdk maven2 tomcat7 squid3

# Enable tomcat7 to bind to port 80.
port=/etc/authbind/byport/80
touch "$port"
chown tomcat7:tomcat7 "$port"
chmod 500 "$port"

if ! options=`getopt -u -o "" \
  -l "git:, git-checkout:, tgz:, tmpdir:, branding:, files:" -- "$@"`; then
  exit 1
fi

set -- $options

while [ $# -gt 0 ]; do
  case $1 in
    --git)
      git=$2
      shift 2
      ;;
    --git-checkout)
      git_checkout=$2
      shift 2
      ;;
    --tgz)
      tgz=$2
      shift 2
      ;;
    --tmpdir)
      tmpdir=$2
      shift 2
      ;;
    --branding)
      branding=$2
      shift 2
      ;;
    --files)
      files=$2
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [ -n "$git" -a -n "$tgz" ]; then
  echo "Can't specify --git and --tgz at the same time" >&2
  exit 1
fi

if [ -z "$git" -a -n "$git_checkout" ]; then
  echo "Can't specify --git-checkout without --git" >&2
  exit 1
fi

if [ -z "$git" -a -z "$tgz" ]; then
  tgz=https://github.com/iipc/openwayback/archive/master.tar.gz
fi

# Initial working directory pre any chdir.
pwd0="$PWD"

cd "$tmpdir"

if [ -n "$git" ]; then
  # Clone a repo.
  git clone "$git"

  # Assume basename is the srcdir, removing suffix if present.
  srcdir=$(basename "$git"|sed 's/\.git$//')
else
  # Fetch a file.
  wget "$tgz"

  # Assume first line in listing is the srcdir.
  srcdir=$(tar ztf $(basename "$tgz")|head -n1|sed 's,/$,,')

  tar zxf $(basename "$tgz")
fi

cd "$srcdir"

if [ -n "$git_checkout" ]; then
  git checkout "$git_checkout"
fi

# Favor Arabic for resources in CP1256 with no info in meta tags.
sed -i 's/DEFAULT_CHARSET = "UTF-8"/DEFAULT_CHARSET = "WINDOWS-1256"/g' \
  wayback-core/src/main/java/org/archive/wayback/replay/charset/CharsetDetector.java

# Compile, skipping tests.
mvn install -Dmaven.test.skip=true

# Deploy ROOT.war to tomcat7.
rm -R /var/lib/tomcat7/webapps/ROOT
cp wayback-webapp/target/openwayback-*-SNAPSHOT.war /var/lib/tomcat7/webapps/ROOT.war

service tomcat7 restart

# This is the base directory as defined in wayback.xml.
mkdir /var/local/openwayback

# Deploy config files and related items.
cd "$pwd0"
cd "$files"

for i in *.tar.gz; do
  tar zxf $i -C /
done

# Add branding to home page.
cd "$pwd0"
cd "$branding"
cp -R policies /var/lib/tomcat7/webapps/ROOT/

echo "AUTHBIND=yes" >>/etc/default/tomcat7

# Increase max heap size and ulimit.
sed -i 's/^\(JAVA_OPTS=.*\)-Xmx[^ ]\+\(.*\)/\1-Xmx1536m\2/' \
  /etc/default/tomcat7
echo "ulimit -n 65536" >>/etc/default/tomcat7

# Allow everyone to read the logs (CollectLog).
chmod 755 /var/log/tomcat7

service tomcat7 restart
