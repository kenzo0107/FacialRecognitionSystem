#!/bin/sh

# train用データ格納閾値
LABEL="$1"
threshold=$2
remain_img_flg=$3

sourceDir="face_detect/${LABEL}"
outTrainDir="out/train/${LABEL}"
outTestDir="out/test/${LABEL}"

if [ ! -d "${outTrainDir}" ]; then
    mkdir -p ${outTrainDir}
    # rm -rf ${outTrainDir}/*
fi

if [ ! -d "${outTestDir}" ]; then
    mkdir -p ${outTestDir}
    # rm -rf ${outTestDir}/*
fi

countTotal=$(ls ${sourceDir}/*.jpg | wc -l | sed 's/    //')

countTrain=0
countTest=0
for file in `ls ${sourceDir}/*.jpg | while read x; do echo -e "$RANDOM\t$x"; done | sort -k1,1n | cut -f 2-`; do

    if [ `expr $RANDOM % 100` -lt ${threshold} ] ; then
        countTrain=$(($countTrain+1))
        if [ "$remain_img_flg" == "" ]; then
            mv ${file} ${outTrainDir}/
        else
            cp ${file} ${outTrainDir}/
        fi
    else
        countTest=$(($countTest+1))
        if [ "$remain_img_flg" == "" ]; then
            mv ${file} ${outTestDir}/
        else
            cp ${file} ${outTestDir}/
        fi
    fi

done

echo "${LABEL}:"
echo "    countTotal:$countTotal"
echo "    countTrain:$countTrain"
echo "    countTest:$countTest"
