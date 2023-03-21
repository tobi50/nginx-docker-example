# AWSでコンテナベースで "Welcome to ntinx" を表示するリソース作成のTerraformサンプルコード

- Terraform実行する前にローカル環境のAWSクレデンシャル設定確認

```
$ cat ~/.aws/credentials
```

- [default] プロファイルが空もしくは何かしら稼働中アカウントのクレデンシャルの場合は下記コマンドで検証環境専用のAWSクレデンシャルをセットアップ

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```

- AWS用Terraformプロジェクトの初期化

```
$ cd aws/ecs
$ terraform init
```

- Plan

```
$ terraform plan
```

- apply

```
$ terraform apply -auto-approve
```

- apply結果からALBのURL (lb_dns_name) をコピーしてブラウザで動作確認

```
Apply complete! Resources: 12 added, 1 changed, 1 destroyed.

Outputs:

lb_dns_name = "nginx-1234567.ap-northeast-1.elb.amazonaws.com"
private_subnets = [
  "subnet-0exxxxxxxxxxe",
...
```

- ブラウザで "Welcome to ntinx" を確認

![nginx](https://user-images.githubusercontent.com/47206868/226575203-79276de9-1dba-41f4-bbbb-8e0b37c6f16e.png)


