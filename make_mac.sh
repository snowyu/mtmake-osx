#!/bin/sh

STARTDIR=`pwd`

# Clone MT source code if not already there
if [ ! -d "minetest-git" ]; then
  git clone https://github.com/minetest/minetest minetest-git
fi

# Get minetest_game if it is not already there
if [ ! -d "minetest_game" ]; then
  git clone https://github.com/minetest/minetest_game
fi

# Update minetest_game from GitHub
(cd minetest_game && git pull)

# Get Carbone if it is not already there
if [ ! -d "carbone" ]; then
  git clone https://git.gitorious.org/calinou/carbone.git
fi

# Update Carbone
(cd carbone && git pull)

# Get Voxelgarden if it is not already there
if [ ! -d "Voxelgarden" ]; then
  git clone https://github.com/CasimirKaPazi/Voxelgarden.git
fi

# Update Voxelgarden
(cd Voxelgarden && git pull)


# Update source code and set version string
cd minetest-git
git checkout master --force
git pull
gitver=`git log -1 --format='%cd.%h' --date=short | tr -d -`

rm -f CMakeCache.txt
cmake . -DCMAKE_BUILD_TYPE=Release -DENABLE_FREETYPE=on -DENABLE_LEVELDB=on -DENABLE_GETTEXT=on -DENABLE_REDIS=on -DBUILD_SERVER=NO -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_CXX_FLAGS="-mmacosx-version-min=10.9 -march=core2 -msse4.1" -DCMAKE_C_FLAGS="-mmacosx-version-min=10.9 -march=core2 -msse4.1" -DCUSTOM_GETTEXT_PATH=/usr/local/opt/gettext

make clean
make VERBOSE=1
cp -p bin/minetest ../releases/minetest.app/Contents/Resources/bin
cd ../releases

# Change library paths in binary to point to bundle directory
./dylibbundler-0.4.4/dylibbundler -x minetest.app/Contents/Resources/bin/minetest -d ./minetest.app/Contents/libs/ -p @executable_path/../../libs/
echo "======== otool ======="

# Print library paths which should now point to the executable path
otool -L minetest.app/Contents/Resources/bin/minetest | grep executable

# Remove shared directories...
(cd minetest.app/Contents/Resources/bin/share && rm -fr builtin client fonts locale textures)

# ...and copy new ones from source code directory
for i in builtin client fonts locale textures
do
cp -pr ../minetest-git/$i minetest.app/Contents/Resources/bin/share
done

# Copy subgames into games directory
rm -fr minetest.app/Contents/Resources/bin/share/games/*
(cd minetest.app/Contents/Resources/bin/share/games && mkdir minetest_game carbone Voxelgarden)
cp -pr $STARTDIR/minetest_game/* minetest.app/Contents/Resources/bin/share/games/minetest_game/
cp -pr $STARTDIR/carbone/* minetest.app/Contents/Resources/bin/share/games/carbone/
cp -pr $STARTDIR/Voxelgarden/* minetest.app/Contents/Resources/bin/share/games/Voxelgarden/

# Create updated Info.plist with new version string
sysver=`sw_vers -productVersion`
sed -e "s/GIT_VERSION/$gitver/g" -e "s/MACOSX_DEPLOYMENT_TARGET/$sysver/g" Info.plist >  minetest.app/Contents/Info.plist

# Compress app bundle as a ZIP file
fname=minetest-osx-bin-$gitver.zip
rm -f $fname
zip -9 -r $fname minetest.app

