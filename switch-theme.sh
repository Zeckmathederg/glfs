#!/bin/sh
if [ "$1" == "light" ]; then
  cp -v stylesheets/lfs-xsl/light.lfs.css stylesheets/lfs-xsl/lfs.css
elif [ "$1" == "dark" ]; then
  cp -v stylesheets/lfs-xsl/dark.lfs.css stylesheets/lfs-xsl/lfs.css
else
  echo '"'"$1"'" is not "light" or "dark"'
fi
