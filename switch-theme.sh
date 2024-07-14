#!/bin/sh
if [ "$1" == "light" ]; then
  ln -svf light.lfs.css stylesheets/lfs-xsl/lfs.css
elif [ "$1" == "dark" ]; then
  ln -svf dark.lfs.css stylesheets/lfs-xsl/lfs.css
else
  echo '"'"$1"'" is not "light" or "dark"'
fi
