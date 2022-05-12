GitHub Actions から Terraform を実行するサンプルです。

Pull Request をトリガーに、下記で定義されているワークフローを実行します。

https://github.com/octodemo/hashicorp-github/tree/main/.github/workflows

実際の Pull Request の例: https://github.com/octodemo/hashicorp-github/pull/3

このサンプルでは、State ファイルの管理 (remote backend) に [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) (無料版) を利用しています。
Terraform Cloud と GitHub Actions を連携する方法の詳細については下記のガイドを参考にしてください。

https://learn.hashicorp.com/tutorials/terraform/github-actions?in=terraform/automation
