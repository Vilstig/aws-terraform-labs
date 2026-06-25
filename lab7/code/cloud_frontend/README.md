# Frontend lab7 — integracja z API Gateway / Lambda

## Zmienne środowiskowe (ECS)

| Zmienna | Opis |
|---------|------|
| `PUBLIC_API_BASE_URL` | Backend Spring przez ALB |
| `PUBLIC_LAMBDA_API_URL` | Bazowy URL API Gateway (stage `prod`) |

Przy wysyłaniu wiadomości frontend:
1. `POST /chat` — czat przez backend (ALB)
2. `POST {PUBLIC_LAMBDA_API_URL}/messages` — Lambda (DynamoDB + SNS przy „placki”)

## Build i push na Docker Hub

```bash
cd lab7/code/cloud_frontend
docker build -t TWOJ_USER/frontend-lab7:latest .
docker login
docker push TWOJ_USER/frontend-lab7:latest
```

## Terraform

W `lab7/variables.tf` lub `terraform.tfvars`:

```hcl
frontend_docker_image = "TWOJ_USER/frontend-lab7:latest"
```

```bash
cd lab7
terraform apply
```

## Test lokalny (opcjonalnie)

```bash
npm ci
PUBLIC_API_BASE_URL=http://localhost:8080 PUBLIC_LAMBDA_API_URL=https://xxx.execute-api.us-east-1.amazonaws.com/prod npm run dev
```
