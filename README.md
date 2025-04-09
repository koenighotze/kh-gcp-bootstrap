# GCP Bootstrap

[![QA for Scripts](https://github.com/koenighotze/kh-gcp-bootstrap/actions/workflows/qa-scripts.yml/badge.svg)](https://github.com/koenighotze/kh-gcp-bootstrap/actions/workflows/qa-scripts.yml)
[![QA Terraform](https://github.com/koenighotze/kh-gcp-bootstrap/actions/workflows/qa-terraform.yml/badge.svg)](https://github.com/koenighotze/kh-gcp-bootstrap/actions/workflows/qa-terraform.yml)

This repository contains everything not setup via Terraform.

- seed project
- seed service account
- downstream projects
  - kh-gcp-seed
  - kh-gcp-platform (TODO)
  - kh-gcp-network (TODO)

## Usage

### Step 0 Things needed

- local.sh setup: TODO
- defaults.auto.tfvars setup: TODO

### Step 1 Bootstrap the seed environment

```shell
./scripts/bootstrap.sh
```

### Step 2 Create downstream projects

```shell
./scripts/create-projects.sh
```

### Step 3 Provision seed infrastructure

```shell
./scripts/tf-local-init.sh
tf plan
tf apply -auto-approve
```
