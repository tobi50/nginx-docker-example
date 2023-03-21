# nginx-docker-example
想定した開発環境：Mac OS
IaSツール:Terraform

前提条件：Homebrewとawscliインストール済み
※インストールしてない場合はは公式サイトを参考しインストールしてください：https://brew.sh/index_ja

IaSツールのTerraformバージョン切り替えを簡単にできるように下記を参考にtfenvをインストールしていきます。

```
$ brew update && brew upgrade
$ brew install tfenv
```

.terraform-versionを配置しているため、Terraform実行時に指定したversionのterraformに切り替えるもしくはインストールが行います。
