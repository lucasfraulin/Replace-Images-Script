#!/bin/bash

# -p /png/image/folder/path
# -j /jpg/image/folder/path
# these can be the same folder as they will only use the pngs for the -p flag
# and the jpgs for the -j flag

while getopts p:j:s: flag
do
    case "${flag}" in
        p) pngImage=${OPTARG};;
        j) jpgImage=${OPTARG};;
    esac
done

declare -A pngArray;
declare -A jpgArray;


for i in $pngImage/*;
do
  if [[ $i == *.png ]]
  then
    pngArray[${#pngArray[@]}]=$i
  fi
done

for i in $jpgImage/*;
do
  if [[ $i == *.jpg ]]
  then
    jpgArray[${#jpgArray[@]}]=$i
  fi
done

# $1 = SEARCH FOLDER
recursiveReplace() {

  jpgCount=0
  pngCount=0

  for i in $1/*;
  do
    if [ -d "$i" ]
    then
      cd $i; recursiveReplace "$i";
    elif [ -f "$i" ]
    then

      if [[ $i == *.png ]]
      then
        if [ -z $pngImage ]
        then
          continue
        else
          replaceImage "${pngArray[$pngCount]}" "$i"
          pngCount=$(($pngCount + 1))
          pngCount=$(($pngCount % ${#pngArray[@]}))
        fi
      elif [[ $i == *.jpg ]]
      then
        if [ -z $jpgImage ]
        then
          continue
        else
          replaceImage "${jpgArray[$jpgCount]}" "$i"
          jpgCount=$(($jpgCount + 1))
          jpgCount=$(($jpgCount % ${#jpgArray[@]}))
        fi
      else
        echo $i
      fi
    fi
  done
  return
}

replaceImage() {
  # $1 = imageToInsert, $2 = imageToReplace
  rsync -ahv $1 $2
}

if [ -d "./web" ]
then
  ROOT='./web'
elif [ -d "./docroot" ]
then
  ROOT='./docroot'
else
  ROOT='./'
fi

SEARCH_ROOT="$ROOT/sites/default/files"
cd $SEARCH_ROOT

recursiveReplace "$PWD"
