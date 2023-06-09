## AWSのECSでコンテナベースで "Welcome to ntinx" を表示するリソース作成のTerraformサンプルコード

- Terraform実行する前にローカル環境のAWSクレデンシャル設定確認

```
$ cat ~/.aws/credentials
```

- [default] プロファイルが空の場合、または既存本番アカウントのクレデンシャルが含まれている場合は、以下のコマンドを使用して検証環境専用のAWSクレデンシャルを設定してください。

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


- 以下のURLにアクセスし、手動でECSタスクの数を0に設定
    - 注意：ECSタスク数が0以外の状態ではdestroyが失敗するためタスク数を手動で0にしてからdestroyします

https://ap-northeast-1.console.aws.amazon.com/ecs/v2/clusters/nginx/services/nginx/update?region=ap-northeast-1
![Amazon_ECS](https://user-images.githubusercontent.com/47206868/226576869-63c433a6-cc89-40ee-87ea-46ba7efb7627.png)

- destroy
    - 動作確認後、Terraformで作成したリソースを削除


```
$ terraform destroy -auto-approve
```
