#!/bin/sh

SETTING="config.txt"

while read line
do
  arr=( `echo $line | tr -s "," ' '`)

  LABEL="${arr[0]}"
  SEARCH_WORD="${arr[1]}"
  NUMBER="${arr[2]}"

  echo "LABEL:${LABEL} - SEARCH_WORD:${SEARCH_WORD}"

  CSV_IMG_URL_LIST="crawler/${LABEL}.csv"
  OUT_IMG_DIR="crawler/imgs/${LABEL}"

  echo << EOU
============================
 顔検出
============================
EOU

  for file in `\find ${OUT_IMG_DIR} -maxdepth 1 -type f`; do
     python face_detect/detect.py $file face_detect/${LABEL}
  done

done < $SETTING
