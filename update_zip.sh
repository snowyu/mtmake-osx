#!/bin/sh

# Create an updated ZIP file from minetest.app folder

cd minetest-git
gitver=`git log -1 --format='%cd.%h' --date=short | tr -d -`
cd ../releases

# Compress app bundle as a ZIP file
fname=minetest-osx-bin-$gitver.zip
rm -f $fname
zip -9 -r $fname minetest.app

