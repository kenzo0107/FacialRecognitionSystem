#!/bin/sh

SETTING="config.txt"

# initialize.
cp /dev/null deeplearning/train.txt
cp /dev/null deeplearning/test.txt

while read line
do
  arr=( `echo $line | tr -s "," ' '`)

  LABEL="${arr[0]}"
  SEARCH_WORD="${arr[1]}"
  NUMBER="${arr[2]}"

  echo "LABEL:${LABEL} - SEARCH_WORD:${SEARCH_WORD}"

  echo << EOV
==============================
 顔検出画像を train, test に分類
==============================
EOV
  sh classify.sh "${LABEL}" 70

  echo << EOW
============================
 訓練画像に分類
============================
EOW
  if [ -e out/train/${LABEL} ];
  then
    python deeplearning/gen_testdata.py out/train "${LABEL}" ${NUMBER} >> deeplearning/train.txt
    echo "---> out/train から label:${LABEL} 付けしたデータを train.txt へ保存\n"
  fi
  if [ -e out/test/${LABEL} ];
  then
    python deeplearning/gen_testdata.py out/test  "${LABEL}" ${NUMBER} >> deeplearning/test.txt
    echo "---> out/test から label:${LABEL} 付けしたデータを test.txt へ保存\n"
  fi

done < $SETTING
