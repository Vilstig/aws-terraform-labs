# AWS Cloud & Terraform Labs

Hands-on coursework progressing from containerized applications to AWS infrastructure defined with **Terraform**. The later labs deploy a full-stack chat application on **ECS Fargate** behind an **Application Load Balancer**, with extensions for **S3** (pre-signed uploads) and **DynamoDB** (chat history).

---

## Repository structure

```
├── lab1/          Docker Compose — local full-stack chat (SvelteKit + Spring Boot)
├── lab2/          Terraform — VPC, subnets, EC2-style networking fundamentals
├── lab3/          Terraform — parameterized EC2 deployment (variables/outputs)
├── lab4/          Terraform — VPC + ALB + ECS Fargate (multi-file modules)
└── lab5/          Terraform — lab4 stack + S3, DynamoDB, VPC endpoints, app extensions
```

### Lab 1 — Containers locally

- **Stack:** SvelteKit frontend, Kotlin/Spring Boot backend
- **Tooling:** Docker Compose (`docker-compose.yml`)
- **Goal:** Run and develop the chat app on localhost before moving to AWS

### Lab 2 — Terraform basics

- Single-configuration introduction to AWS provider and core resources
- VPC, public/private subnets, routing, EC2-related resources

### Lab 3 — Variables & outputs

- Refactored Terraform with `variables.tf` and `outputs.tf`
- EC2 instance behind VPC networking (SSH key name via variable — **do not commit `.pem` files**)

### Lab 4 — ECS on AWS (recommended sample)

| File | Purpose |
|------|---------|
| `network.tf` | VPC, multi-AZ public subnets, IGW, routing |
| `security.tf` | Security groups for ALB and ECS tasks |
| `alb.tf` | Application Load Balancer, listeners, target groups |
| `ecs.tf` | ECS cluster, Fargate task definitions & services |
| `variables.tf` | Region, CIDRs, CPU/memory, Docker images |
| `outputs.tf` | ALB DNS, frontend/backend URLs |

### Lab 5 — Extended cloud-native stack

Builds on lab 4 and adds:

- **S3** — private bucket for chat images; browser upload/download via **pre-signed URLs**
- **DynamoDB** — optional chat history persistence (`PAY_PER_REQUEST`)
- **VPC gateway endpoints** — S3 and DynamoDB traffic stays on the AWS network
- **Split security groups** — dedicated SGs for frontend vs backend tasks
- **IAM** — `task_role_arn` on backend tasks only (S3/DynamoDB access)

Key Terraform files: `s3.tf`, `dynamodb.tf`, plus updates to `network.tf`, `security.tf`, `ecs.tf`, `locals.tf`.

Application changes live under `lab5/cloud_frontend/` and `lab5/cloud_backend/`.

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) ≥ 1.x
- AWS account with credentials configured (`aws configure` or environment variables)
- IAM permissions compatible with lab resources (labs often use a pre-provisioned role such as `LabRole` for ECS execution)
- For **lab 1:** Docker & Docker Compose
- For **lab 5 app build:** Node.js (frontend), JDK/Gradle (backend) — only if building images yourself; labs can use published Docker images via variables

---

## Quick start (Lab 5 — infrastructure)

```bash
cd lab5
terraform init
terraform plan
terraform apply
```

After apply, check outputs:

```bash
terraform output
```

Typical outputs: `alb_dns_name`, `frontend_url`, `backend_url`, `s3_bucket_name`, `dynamodb_table_name`.

### Lab 1 — local app

```bash
cd lab1
docker compose up --build
```

Frontend: `http://localhost:3000` · Backend: `http://localhost:8080`

---

## API endpoints (Lab 5 extensions)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/chat/upload-url` | Returns pre-signed PUT URL for image upload to S3 |
| `POST` | `/chat/history/save` | Persists in-memory chat to DynamoDB; returns `chatId` |
| `GET` | `/chat/history/{chatId}` | Loads saved chat history |

---

## Design decisions (summary)

- **DynamoDB over RDS** for chat history: serverless, pay-per-request, no VPC DB subnet complexity; fits simple key-value access patterns.
- **Pre-signed S3 URLs:** files go browser → S3 directly; backend never proxies large uploads.

---

## Tech stack

| Layer | Technologies |
|-------|----------------|
| IaC | Terraform, AWS Provider |
| AWS | VPC, ECS Fargate, ALB, S3, DynamoDB, CloudWatch, IAM |
| Backend | Kotlin, Spring Boot |
| Frontend | SvelteKit, TypeScript |
| Local dev | Docker Compose |

---

