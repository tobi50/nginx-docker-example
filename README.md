## コンテナベースで "Welcome to ntinx" を表示するリソース作成のTerraformサンプルコード

動作確認はすべて、macOS上で行っています。
バージョンは次のとおりです。

- Terraform：1.4.3 (tfenvを利用するため、事前インストールは不要です)
- AWSプロバイダ：4.59.0

これ以降のバージョンであれば概ね動くと思いますが、うまく動かない場合は上記のバージョンをお試しください。

前提条件：
Homebrewとawscliインストール済み
※インストールしてない場合はは公式サイトを参考しインストールしてください：https://brew.sh/index_ja

Terraformバージョン切り替えを簡単にできるように下記を参考にtfenvをインストールしていきます。

```
$ brew update && brew upgrade
$ brew install tfenv
```

.terraform-versionを配置しているため、Terraform実行時に指定したversionのterraformに切り替えるもしくはインストールが行います。

