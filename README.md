```
 _____                     __                               _                            __ _
/__   \___ _ __ _ __ __ _ / _| ___  _ __ _ __ ___     /\/\ (_)_ __   ___  ___ _ __ __ _ / _| |_
  / /\/ _ \ '__| '__/ _` | |_ / _ \| '__| '_ ` _ \   /    \| | '_ \ / _ \/ __| '__/ _` | |_| __|
 / / |  __/ |  | | | (_| |  _| (_) | |  | | | | | | / /\/\ \ | | | |  __/ (__| | | (_| |  _| |_
 \/   \___|_|  |_|  \__,_|_|  \___/|_|  |_| |_| |_| \/    \/_|_| |_|\___|\___|_|  \__,_|_|  \__|
```

![preview](preview.gif)

## Setup
- Generate an SSH key if you don't already have one with `ssh-keygen -t rsa -b 4096`.
- [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (tested on 1.1.3).
- [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
- [Configure the AWS CLI with an access key ID and secret access key](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

## Steps
- Run `terraform init`.
- Run `terraform apply`.
- Wait a minute for the server to spin up.
- Connect to http://squirbicous.com
- Play Minecraft
- Irrecoverably shut everything down with `terraform destroy`.
