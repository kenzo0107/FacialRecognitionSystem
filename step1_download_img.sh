#!/bin/sh

SETTING="config.txt"

while read line
do
  arr=( `echo $line | tr -s "," ' '`)

  LABEL="${arr[0]}"
  SEARCH_WORD="${arr[1]}"
  NUMBER="${arr[2]}"

  echo "LABEL:${LABEL} - SEARCH_WORD:${SEARCH_WORD}"

  echo << EOS
============================================
 datamarket から検索しダウンロード画像一覧CSV作成
============================================
EOS
  ruby crawler/url_fetch.rb "$LABEL" "$SEARCH_WORD"

  echo << EOT
============================
 画像URL一覧CSVより画像取得
============================
EOT

  CSV_IMG_URL_LIST="crawler/${LABEL}.csv"
  OUT_IMG_DIR="crawler/imgs/${LABEL}"
  ruby crawler/download.rb ${CSV_IMG_URL_LIST} ${OUT_IMG_DIR}

done < $SETTING
