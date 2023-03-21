## コンテナベースで "Welcome to ntinx" を表示するリソース作成のTerraformサンプルコード

動作確認はすべて、macOS上で行っています。
バージョンは次のとおりです。

- Terraform：1.4.3 (tfenvを利用するため、事前インストールは不要です)
- AWSプロバイダ：4.59.0

これ以降のバージョンであれば概ね動くと思いますが、うまく動かない場合は上記のバージョンをお試しください。

### 前提条件：
- AWSの管理者権限を持つクレデンシャルをお持ちである必要があります。
- Homebrewとawscliがインストールされている必要があります。
※インストールしてない場合はは公式サイトを参考しインストールしてください：https://brew.sh/index_ja

### 事前準備：
- Terraformバージョン切り替えを簡単にできるように下記を参考にtfenvをインストールしていきます。

https://github.com/tfutils/tfenv

```
$ brew update && brew upgrade
$ brew install tfenv
```

.terraform-versionを配置しているため、Terraform実行時に指定したversionのterraformに切り替えるもしくはインストールが行います。


### リポジトリ構成
IaaSごとにマネージドサービス別にサンプルコードを分けています。ローカルからの実行方法については、それぞれのREADMEを参照してください。
今回は、AWSのECSを使用して「Welcome to nginx」と表示されるIaC（Infrastructure as Code）実装をローカル環境から実行します。

```
aws
  |_ecs
```
