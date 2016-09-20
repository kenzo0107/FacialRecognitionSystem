#!/usr/bin/env python
#! -*- coding: utf-8 -*-

import sys
import numpy as np
import cv2
import tensorflow as tf #cv2より前にimportするとcv2.imreadになぜか失敗する(Noneを返す)
import os
import input
import model
import json

def evaluation(imgpath, ckpt_path):
    tf.reset_default_graph()

    jpeg = tf.read_file(imgpath)
    image = tf.image.decode_jpeg(jpeg, channels=3)
    image = tf.cast(image, tf.float32)
    image.set_shape([input.IMAGE_SIZE, input.IMAGE_SIZE, 3])
    image = tf.image.resize_images(image, input.DST_INPUT_SIZE, input.DST_INPUT_SIZE)
    image = tf.image.per_image_whitening(image)
    image = tf.reshape(image, [-1, input.DST_INPUT_SIZE * input.DST_INPUT_SIZE * 3])
    # print image

    logits = model.inference_deep(image, 1.0, input.DST_INPUT_SIZE, input.get_count_member())

    sess = tf.InteractiveSession()
    saver = tf.train.Saver()
    sess.run(tf.initialize_all_variables())
    if ckpt_path:
        # print "ckpt_path:", ckpt_path
        saver.restore(sess, ckpt_path)

    softmax = logits.eval()

    result = softmax[0]
    rates = [round(n * 100.0, 1) for n in result]
    # print "rates:", rates

    pred = np.argmax(result)

    members = []
    member_names = input.get_member_name()
    for idx, rate in enumerate(rates):
        name = member_names[idx]
        members.append({
            'name_ascii': name[1],
            'name': name[0],
            'rate': rate
        })
    rank = sorted(members, key=lambda x: x['rate'], reverse=True)

    return (rank, pred)

def execute(imgpaths, ckpt_path):
    res = []
    for imgpath in imgpaths:
        (rank, pred) = evaluation(imgpath, ckpt_path)
        res.append({
            'file': imgpath,
            'top_member_id': pred,
            'rank': rank
        })
    enc = json.dumps(res)
    dec = json.loads(enc)
    return dec

if __name__ == '__main__':
    ckpt_path = sys.argv[1]
    imgfile1 = sys.argv[2]
    res = execute([imgfile1], ckpt_path)
    l={}
    for v in res[0]['rank']:
        l[v['name_ascii']] = v['rate']
    print "%s,%s"%(imgfile1,l)
#     print '''
# ------------------------------
# Result
# ------------------------------
#     '''
#     for v in res:
#         # print v['rank']
#         for r in v['rank']:
#             print r
