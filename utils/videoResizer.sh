#!/bin/bash

#
# video conversion script for publishing as HTML 5 video
# 2011 by zpea
# 2014 by ninerian
# feel free to use as public domain / Creative Commons CC0 1.0 (http://creativecommons.org/publicdomain/zero/1.0/)
#

FFMPEG=/usr/local/bin/ffmpeg

# WIDTHS=('2560' '2048' '1920' '1344' '1024')
# HEIGHTS=('1280' '1024' '960' '672' '512')

WIDTHS=('2560' '2048' '1920')
HEIGHTS=('1280' '1024' '960')

DESCR_H264='mp4 (h.264/aac)'
DESCR_WEBM='webm (vp8/vorbis)'
DESCR_OGG='ogv (theora/vorbis)'

function usage(){
  echo
  echo
  echo usage:
  echo $0' <input video file>' $1' <destination>' $2' <path to logo file>' $3
  echo
  echo 
  echo 'The input video file is converted to '$DESCR_H264', '$DESCR_WEBM' and '$DESCR_OGG' videos.'
  echo
  echo
  echo 'All output files are created in the current working directory and named according to the input file'\''s name' 
  echo
  echo
}
#ffmpeg -i $i -i logo_erg_2015.tiff -filter_complex "overlay=(W-w)/2:(H-h)" -codec:a copy logo/${i%.*}.mp4

# exactly one argument required
if [[ ($# -ne 1) && ($# -ne 2) && ($# -ne 3) ]]
then
  usage
  exit 1
fi

INFILE=$1
if [ ! -f $INFILE ];
then
  echo 'Input file does not exist or is not a regular file'
  exit 2
fi

if [ -z "$2" ];
  then
    OUTDIR='.'
  else
    OUTDIR=$2
fi

echo $1;
echo $2;
echo $3;

if [ ! -d $OUTDIR ]
  then
  echo "Output directory doesn't exist so I'am creating it for you."
  mkdir  "$OUTDIR"
fi





BASENAME=${1##*/}
BASE_WITHOUT_EXT=${BASENAME%.*}
FILENAME=$(expr $BASE_WITHOUT_EXT : '^\(.[a-z,0-9]*_.[a-z,0-9]*\)');

if [ ! -z "$3" ];
  then
  if [ ! -d 'tmp' ]
    then
    echo "Temp directory doesn't exist so I'am creating it for you."
    mkdir  "tmp"
  fi

  $FFMPEG -hide_banner -i $INFILE -i $3 -filter_complex "overlay=(W-w)/2:(H-h)" -codec:a copy tmp/${INFILE%.*}.mp4
  INFILE=tmp/$INFILE;
fi

# should be unnecessary thanks to -vpre baseline
#H264_OPTS_BASELINE="-vcodec libx264 -b 512k -flags +loop+mv4 -cmp 256 -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 -me_method hex -subq 7 -trellis 1 -refs 5 -bf 0 -flags2 +mixed_refs -coder 0 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -qmin 10 -qmax 51 -qdiff 4"
for i in "${!WIDTHS[@]}";
  do
    width=${WIDTHS[$i]};
    height=${HEIGHTS[$i]};
    fileName=${OUTDIR}/${FILENAME}_${width}x${height};
    echo 
    echo 
    echo ================================================================
    echo '   Starting conversion to SD '$DESCR_H264
    echo '   output to '$fileName.mp4
    echo ================================================================
    echo
    $FFMPEG -hide_banner -i $INFILE -vcodec libx264 -acodec aac -strict -2 -pix_fmt yuv420p -threads 16 -profile:v high -level 4.0 -preset slow -crf 22 -f mp4 -vf "scale=$width:-1" -movflags +faststart $fileName.mp4

    echo
    echo ================================================================
    echo '   Starting conversion to SD '$DESCR_WEBM
    echo '   output to '$fileName.webm
    echo ================================================================
    echo

    $FFMPEG -hide_banner -i $INFILE -c:v libvpx -f webm -vcodec libvpx -g 120 -lag-in-frames 16 -threads 16 -deadline good -cpu-used 16 -vprofile 0 -pix_fmt yuv420p  -qmax 51 -qmin 11 -slices 4 -b:v 2M -acodec libvorbis -ab 112k -ar 44100 -vf "scale=$width:-1" -movflags +faststart $fileName.webm

    echo
    echo ================================================================
    echo '   Starting conversion to SD '$DESCR_OGG
    echo '   output to '$fileName.ogv
    echo ================================================================
    echo
    
    $FFMPEG -hide_banner -i $INFILE  -threads 16 -pix_fmt yuv420p -f ogg -vcodec libtheora -c:v libtheora -c:a libvorbis -q:v 5 -vf "scale=$width:-1" -movflags +faststart $fileName.ogv

   
    echo
    echo ================================================================
    echo '   Creating poster jpeg (frame at 5s)'
    echo ================================================================
    echo
    $FFMPEG -hide_banner -i $INFILE -ss 00:05 -vf "scale=$width:-1" -vframes 1 -r 1 -f image2 $fileName.jpg

done




