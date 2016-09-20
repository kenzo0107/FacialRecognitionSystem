# 顔認識システム

## 環境

- MacOSX 10.11.5
- Python 2.7.10
- pip 8.1.2

## セットアップ手順

### MacOS に Python2, Python3 仮想環境構築

- [MacOSX に Python2, Python3 仮想環境構築](http://kenzo0107.hatenablog.com/entry/2016/07/28/143429)

### pip モジュールインストール

```
$ git clone https://github.com/kenzo0107/FacialRecognitionSystem
$ cd FacialRecognitionSystem
$ pip install -r requirements.txt
```

### Bing Search API Key 取得

1. Microsoftアカウント作成
2. [Azure Marketplace](https://datamarket.azure.com/dataset/bing/search)で 5000トランザクション/月 プラン(無料)選択
3. Azure Marketplaceのマイアカウントのアカウントキーでキーの値を取得する

### 顔認識したいラベルとナンバリング

- 設定ファイル config.txt

```sh
nakai,中居正広,0
kimura,木村拓哉,1
katori,香取慎吾,2
kusanagi,草彅剛,3
inagaki,稲垣吾郎,4
```

|- *Item*-|- *Explain* -|
|---|---|
|nakai|ラベリング。画像を格納するディレクトリ等で利用|
|中居正広|検索ワードとして利用|
|0|ナンバリング。画像のラベル付けする際に利用。0始まり|


## 使い方

### Step1. Bing 検索エンジンから画像ダウンロード

- Bing 検索エンジンから画像検索し画像URLをCSVファイルにまとめる。
- CSVファイルにある画像をダウンロード

```
$ sh step1_download_img.sh
```

### Step2. ダウンロードした画像から顔検知し顔部分のみ抜き取る

- face_detect/<label (例: nakai)>/ にトリミング画像を保存
- トリミングした画像の中には、顔でないものや、別のメンバーの顔が入り込んでいることもあるので、そこは手動で削除  
いずれモデルの精度が上がれば、自動で違うものは削除する、ような仕組みにしたい！


```
$ sh step2_trimming_face.sh
```


### Step3. 分類

- face_detect/<label> から out/train/<label>, out/test/<label> へ 7:3 で振り分ける。
- 振り分ける際にラベリングして deeplearning/train.txt, deeplearning/test.txt へ格納

```
$ sh step3_classify.sh
```

### Step4. ディープライーニングしモデル作成

- out/train/<label> から学習しモデルを作成

```
$ sh step4_create_learning_model.sh
```

### Step5. 評価

- out/test/<label> に格納されている画像をモデルを利用し評価
- 評価対象の各画像がどのメンバーであるか確率をログに吐く。

```
$ sh step5_eval.sh </path/to/model.ckpt>
```



## 補足

今回は芸能人の判定でしたが  
一般人の顔判定をしたい等の場合ネット上に画像ない場合が多いかと思います。

そんなときは直接 crawler/imgs/<somebody> にディレクトリ作ってそこに格納してください。

## 参照
- [TensorFlowによるディープラーニングで、アイドルの顔を識別する](http://memo.sugyan.com/entry/20160112/1452558576)
