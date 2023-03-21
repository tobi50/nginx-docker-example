# nginx-docker-example

- Terraform実行する前にローカル環境のAWSクレデンシャル設定を確認してください。

```
$ cat ~/.aws/credentials
```

- [default] プロファイルが空もしくは何かしら稼働中アカウントのクレデンシャルの場合は検証環境専用のAWSクレデンシャルをセットアップします。

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```
