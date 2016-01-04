#!/bin/bash
# Hulk smash used to compress and optimize 
# large directories of PNG files.
# Usage: ./hulksmash -d ~/PATH/TO/PNGS
# **********************************************
# Depencencies
#  - OS X 10.6-10.7
#  - curl
#  - pngquant (http://pngquant.org/)
#  - ImageOptim (http://imageoptim.com/)
# **********************************************
# Written by Johnathan Hok (john@imusion.net)
# Version 1.0
# **********************************************

VERSION=1.0

# Check for mandatory command line argument
while getopts ":d:" opt; do
  case $opt in
    d)
      DIRECTORY=$OPTARG
    ;;
  esac
done

if [ -z "$DIRECTORY" ]
then
    echo "usage: hulksmash -d ~/PATH/TO/PNGS" >&2
    exit 1
fi

echo "Welcome to Hulk Smash v"$VERSION
echo "-------------------------------"

# Check dependencies
command -v pngquant >/dev/null 2>&1 || { 
  echo "Required dependency pngquant is not found.. currently installing..."
  echo "Program may prompt for password if this script isn't running with sudo..."
  curl -o pngquant.tar.bz2 http://pngquant.org/pngquant.tar.bz2
  tar jxvf pngquant.tar.bz2 pngquant
  sudo mv -f pngquant /usr/bin
  rm pngquant.tar.bz2
  echo "-------------------------------"
}

if [ -z "`system_profiler SPApplicationsDataType | grep ImageOptim`" ]
  then
    echo "Required dependency ImageOptim is not found.. currently installing..."
    echo "Program may prompt for password if this script isn't running with sudo..."
    curl -o ImageOptim.tbz2 http://imageoptim.com/ImageOptim.tbz2
    tar jxvf ImageOptim.tbz2 ImageOptim.app
    sudo mv -f ImageOptim.app /Applications
    rm ImageOptim.tbz2
    echo "-------------------------------"
fi

SUFFIX=$(date +"%Y%m%d%H%M")
ORIGINAL_FILE_SIZE=`find $DIRECTORY -type f -name "*.png" -ls | awk '{total += $7} END {print total/1024}'`
BACKUP_DIRECTORY=$DIRECTORY/../hulksmash-backup-$SUFFIX

# Backup the directory
cp -Rn $DIRECTORY $BACKUP_DIRECTORY

echo "Backed up files to: $BACKUP_DIRECTORY"
echo "Running PNGs through pngquant..."
find $DIRECTORY -name '*.png' -print0 | xargs -0 pngquant --speed 1 --iebug --ext .png --force 256
echo "To continue, please exit ImageOptim when it is complete..."
find $DIRECTORY -name '*.png' -print0 | xargs -0 open -W -n -a ImageOptim.app

OPTIMIZED_FILE_SIZE=`find $DIRECTORY -type f -name "*.png" -ls | awk '{total += $7} END {print total/1024}'`
PERCENT_SAVED=$ORIGINAL_FILE_SIZE-$OPTIMIZED_FILE_SIZE

echo "All your PNG files have been hulk smashed!"
echo "-------------------------------"
echo "Total size of original PNG files: "$ORIGINAL_FILE_SIZE"KB"
echo "Total size of optimized PNG files: "$OPTIMIZED_FILE_SIZE"KB"
SAVED_KB=`echo $ORIGINAL_FILE_SIZE-$OPTIMIZED_FILE_SIZE|bc`
SAVED_PERCENT=`echo "scale=5; ($SAVED_KB/$ORIGINAL_FILE_SIZE)*100"|bc`
echo "*********************************************************"
echo "PNG files hulk smashed by "$SAVED_PERCENT"% saving "$SAVED_KB"KB"
echo "*********************************************************"