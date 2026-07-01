# Top Movers Dashboard

A serverless app that tracks a fixed watchlist of 6 stocks, records the biggest daily mover, and displays the last 7 days of winners in a Vue dashboard. 

All AWS resources are provisioned with Terraform.

Project by Brandon Soto.

---

## Architecture

```
                ┌──────────────────────┐
   EventBridge  │  Cron Lambda (Node)  │   11 PM Pacific / daily
   (Scheduler) ─▶│  fetch 6 quotes,    │
                │  pick biggest mover  │
                └──────────┬───────────┘
                           │ PutItem
                           ▼
                 ┌───────────────────┐
                 │  DynamoDB table   │  one item per day (the winner)
                 └─────────┬─────────┘
                           │ Query (last 7)
                ┌──────────▼───────────┐
   Browser ────▶│  HTTP API Gateway    │   GET /movers
                │  + API Lambda (Node) │
                └──────────┬───────────┘
                           │ JSON
                           ▼
                ┌───────────────────┐
   Browser ────▶│  S3 static site   │  Vue SPA (built to dist/)
                └───────────────────┘
```

**Daily winner rule:** the ticker with the largest absolute percent change
wins, gain or loss. Ties are broken by the higher closing price. The stored
`pctChange` is signed so the frontend knows which color to render.

---

## Repository layout

```
.
├── README.md
├── .gitignore
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml     # fmt / validate / plan on infra/ changes
│       └── frontend-ci.yml      # npm ci + build on frontend/ changes
│
├── infra/                       # Terraform + Lambda handlers
│   ├── .env.example             # TF_VAR_market_api_key template
│   ├── versions.tf              # provider versions (aws, archive, random)
│   ├── variables.tf             # all input variables
│   ├── dynamodb.tf              # movers table (PK + date SK)
│   ├── iam.tf                   # cron Lambda execution role
│   ├── lambda.tf                # cron Lambda + zip packaging
│   ├── apigateway.tf            # HTTP API + read Lambda + IAM
│   ├── eventbridge.tf           # EventBridge Scheduler (11 PM Pacific)
│   ├── s3_website.tf            # S3 static website hosting
│   ├── outputs.tf               # api_invoke_url, site_bucket_name, etc.
│   └── lambda/
│       └── src/
│           ├── index.mjs        # cron handler — fetches quotes, picks winner, writes DDB
│           └── movers.mjs       # GET /movers handler — queries last 7 rows
│
└── frontend/                    # Vue 3 + Vite + Tailwind dashboard
    ├── .env.example             # VITE_API_BASE_URL template
    ├── index.html               # HTML entry point + Google Fonts
    ├── package.json             # pinned dependencies (no ^ ranges)
    ├── package-lock.json        # lockfile for reproducible installs
    ├── vite.config.js           # Vite config + @ path alias
    ├── tailwind.config.js       # dark theme tokens (navy, gain, loss, etc.)
    ├── postcss.config.js        # Tailwind + autoprefixer pipeline
    ├── styles.css               # @tailwind directives + radial gradient body
    └── src/
        ├── main.js              # Vue app entry point
        ├── App.vue              # root component — fetch, state, tab routing
        └── components/
            ├── TabBar.vue       # Daily / History / Trends pill tab switcher
            ├── DailyView.vue    # hero card: ticker, date, close price, % badge + 7-day stats
            ├── HistoryView.vue  # 7-day card grid; clicking a card opens Daily detail
            └── MoverCard.vue    # compact glass card (date, ticker, price, % badge, bar)
      
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Node.js](https://nodejs.org) | 22 LTS | Lambda handlers + frontend build |
| [AWS CLI](https://aws.amazon.com/cli/) | v2 | Credential setup + S3 sync |
| [Terraform](https://www.terraform.io/) | ≥ 1.5 | Provision AWS resources |
| An AWS account | Free Tier | Where everything runs |
| A [Massive](https://massive.com) API key | Free tier | Market data |

---

## Getting started

### 1. Clone the repo

```bash
git clone https://github.com/BrandonMager/StockServerlessPipeline.git
cd StockServerlessPipeline
```

### 2. Configure AWS credentials

Create a dedicated IAM user (never use root) with programmatic access keys,
then run:

```bash
aws configure
#   AWS Access Key ID:     AKIA...
#   AWS Secret Access Key: ...
#   Default region name:   us-west-1
#   Default output format: json
```

Confirm you're pointing at the right account:

```bash
aws sts get-caller-identity
```

### 3. Set up the infra environment

```bash
cp infra/.env.example infra/.env
# edit infra/.env — set TF_VAR_market_api_key to your Massive API key
source infra/.env
```

### 4. Deploy the infrastructure

```bash
cd infra
terraform init       # downloads providers (aws, archive, random)
terraform plan       # review what will be created
terraform apply
```

Note the outputs — you need two of them in the next step:

```bash
terraform output -raw api_invoke_url     # → goes in frontend/.env
terraform output -raw site_bucket_name   # → S3 sync target
terraform output -raw website_endpoint   # → the public URL
```

### 5. Set up the frontend environment

```bash
cp frontend/.env.example frontend/.env
# edit frontend/.env — set VITE_API_BASE_URL to the api_invoke_url above
# (no trailing /movers — the app appends it)
```

### 6. Build and deploy the frontend

```bash
cd frontend
npm install
npm run build

BUCKET=$(cd ../infra && terraform output -raw site_bucket_name)
aws s3 sync ./dist "s3://$BUCKET" --delete
```

### 7. Open the dashboard

```bash
open "$(cd infra && terraform output -raw website_endpoint)"
```

---

## Local development

**Run the frontend locally against the live API:**

```bash
cd frontend
npm run dev          # opens http://localhost:5173
```

**Manually trigger the cron job** (no payload = uses today's Pacific date):

```bash
aws lambda invoke --function-name stock-serverless-pipeline-cron \
  --cli-binary-format raw-in-base64-out /dev/stdout
```

**Backfill a specific date:**

```bash
aws lambda invoke --function-name stock-serverless-pipeline-cron \
  --payload '{"date":"2026-06-26"}' \
  --cli-binary-format raw-in-base64-out /dev/stdout
```

**Watch logs:**

```bash
aws logs tail /aws/lambda/stock-serverless-pipeline-cron --since 10m --follow
aws logs tail /aws/lambda/stock-serverless-pipeline-movers --since 10m --follow
```

**Query the table directly:**

```bash
aws dynamodb query --table-name stock-serverless-pipeline-movers \
  --key-condition-expression "PK = :pk" \
  --expression-attribute-values '{":pk": {"S": "MOVER"}}' \
  --no-scan-index-forward --limit 7
```

> Treat the AWS console as **read-only**. Changing resources by hand creates
> drift from Terraform state. All permanent changes go through `.tf` files.

---

## Backend API

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/movers` | Last 7 daily winners, newest first |

Example response:

```json
[
  {
    "date": "2026-06-29",
    "ticker": "TSLA",
    "pctChange": -8.04,
    "closePrice": 412.55
  }
]
```

Response is cached for 1 hour (`Cache-Control: public, max-age=3600`).

---

## Schedule

The cron runs daily at **11 PM Pacific** (DST-aware via EventBridge Scheduler). It fetches each ticker's daily open/close from Massive, computes `((close - open) / open) * 100`, picks the winner by largest absolute change, and writes one row to DynamoDB.

Weekends and holidays produce no data — the function handles this gracefully and writes nothing rather than erroring.

---

## Secrets

| Secret | Where it lives | How it's used |
|--------|---------------|---------------|
| AWS access keys | `~/.aws/credentials` via `aws configure` | Terraform + AWS CLI |
| Massive API key | `infra/.env` (gitignored), `source`d before Terraform | Injected into cron Lambda env |
| API base URL | `frontend/.env` (gitignored), Vite-loaded at build time | Frontend fetch target |

Terraform state can contain secret values in plaintext — `*.tfstate` is gitignored. For team use, configure the remote S3 backend in the commented `backend "s3"` block in `versions.tf`.

---

## Tear down

Empty the S3 bucket first, then destroy everything:

```bash
BUCKET=$(cd infra && terraform output -raw site_bucket_name)
aws s3 rm "s3://$BUCKET" --recursive
cd infra && terraform destroy
```