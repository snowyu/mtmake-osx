#!/bin/sh

if [ ! -d "minetest-git" ]; then
  git clone https://github.com/minetest/minetest minetest-git
fi

cd minetest-git
git checkout master --force
git pull
gitver=`git log -1 --format='%cd.%h' --date=short | tr -d -`

patch -p1 < ../mt2.patch||echo "*** patching failed"
rm CMakeCache.txt
cmake -G Xcode .
xcodebuild clean
xcodebuild ARCHS="x86_64"
cp -p bin/Debug/minetest ../releases/minetest.app/Contents/Resources/bin
cd ../releases
./dylibbundler-0.4.4/dylibbundler -x minetest.app/Contents/Resources/bin/minetest -d ./minetest.app/Contents/libs/ -p @executable_path/../../libs/
echo "======== otool ======="
otool -L minetest.app/Contents/Resources/bin/minetest | grep executable

if [ ! -d "minetest.app/Contents/Resources/bin/share/games/minetest_game" ]; then
  git clone https://github.com/minetest/minetest_game minetest.app/Contents/Resources/bin/share/games/minetest_game
fi

(cd minetest.app/Contents/Resources/bin/share/games/minetest_game && git pull)

(cd minetest.app/Contents/Resources/bin/share && rm -r builtin client fonts textures)

for i in builtin client fonts textures
do
cp -pr ../minetest-git/$i minetest.app/Contents/Resources/bin/share
done

sed -e "s/GIT_VERSION/$gitver/g" Info.plist >  minetest.app/Contents/Info.plist

fname=minetest-osx-bin-`date +%y%m%d`.zip
rm -f $fname
zip -9 -r $fname minetest.app

