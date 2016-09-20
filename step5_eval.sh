#!/bin/sh

# sh eval.sh </path/to/model>

# モデルパス
MODEL_CKPT=$1

SETTING="config.txt"


LOG=eval.log
touch $LOG
cp /dev/null $LOG

while read line
do
  arr=( `echo $line | tr -s "," ' '`)

  LABEL="${arr[0]}"
  SEARCH_WORD="${arr[1]}"
  NUMBER="${arr[2]}"

  echo "LABEL:${LABEL} :${SEARCH_WORD}"
  # sourceDir="out/test/${LABEL}"

  for file in `ls out/test/${LABEL}/*.jpg | sort -k1,1n | cut -f 2-`;
  do
    # echo "$file"
    l=$(python deeplearning/eval.py $MODEL_CKPT $file | grep -v 'Tensor')
    # echo "$l"
    echo "$l" >> $LOG
  done

done < $SETTING
