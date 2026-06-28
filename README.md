# Top Movers Dashboard
 
A small serverless app that tracks a fixed watchlist of stocks, records the
single biggest daily mover, and displays the last 7 days of winners in a Vue
dashboard. Gains render green, losses render red.
 
All AWS resources are provisioned with Terraform to ensure that no resource is created by hand in the console.
 
---
 
## Architecture
 
```
                ┌──────────────────────┐
   EventBridge  │  Cron Lambda (Node)  │   once / 24h
   (schedule) ─▶│  fetch 5 quotes,     │
                │  pick biggest mover  │
                └──────────┬───────────┘
                           │ PutItem
                           ▼
                 ┌───────────────────┐
                 │  DynamoDB table   │  one item per day (the winner)
                 └─────────┬─────────┘
                           │ Query (last 7)
                ┌──────────▼───────────┐
   Browser ────▶│  API Gateway         │   GET /movers
                │  + API Lambda (Node) │
                └──────────┬───────────┘
                           │ JSON
                           ▼
                ┌───────────────────┐
   Browser ────▶│  S3 static site   │  Vue SPA (built to dist/)
                └───────────────────┘
```
 
**Daily winner rule:** the ticker with the largest *absolute* percent change
wins, whether it's a gain or a loss. Ties are broken by the higher closing
price. The stored `pctChange` is **signed**, so the frontend knows gain vs loss.
 