import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb"

const TABLE_NAME = process.env.TABLE_NAME
const TICKERS = process.env.TICKERS.split(",")
const MARKET_API_KEY = process.env.MARKET_API_KEY
const MASSIVE_BASE_URL = process.env.MASSIVE_BASE_URL || "https://api.massive.com"

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}))

async function fetchTicker(ticker, date) {
    const url = `${MASSIVE_BASE_URL}/v1/open-close/${encodeURIComponent(ticker)}/${date}?adjusted=true&apiKey=${encodeURIComponent(MARKET_API_KEY)}`;
    const res = await fetch(url)

    if (res.status === 404) return null

    if (!res.ok){
        throw new Error(`Massive API ${res.status} for ${ticker} on ${date}`)
    }

    const data = await res.json()
    if(data.status !== "OK"){
        return null;
    }

    const percentChange = ((data.close - data.open) / data.open) * 100
    return {
        pctChange: Math.round(percentChange * 100) / 100,
        closePrice: data.close
    }
}

export function pickWinner(quotes) {
    return Object.entries(quotes).reduce((best, [ticker, quote]) => {
        if(best === null) return { ticker, ...quote}
        const movement = Math.abs(quote.pctChange) > Math.abs(best.pctChange)
        const tie = Math.abs(quote.pctChange) === Math.abs(best.pctChange)
        if (movement || (tie && quote.closePrice > best.closePrice)) {
            return { ticker, ...quote}
        }

        return best
    }, null)
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export async function handler(event){
    const date = event?.date || new Date().toISOString().slice(0, 10)
    const results = []

    for (let i = 0; i < TICKERS.length; i++) {
        const t = TICKERS[i];
        results.push([t, await fetchTicker(t, date)]);
        if (i < TICKERS.length - 1) {
            await sleep(5000); 
        }
    }

    console.log(results)
    
    const quotes = Object.fromEntries(results.filter(([ , quote]) => quote !== null))

    if(Object.keys(quotes).length === 0){
        console.log(`No quotes for ${date}. Nothing written to DB`)
        return { date, written: false}
    }

    const winner = pickWinner(quotes)

    await ddb.send(
        new PutCommand({
            TableName: TABLE_NAME,
            Item: {
                PK: "MOVER",
                SK: date,
                ticker: winner.ticker,
                pctChange: winner.pctChange,
                closePrice: winner.closePrice
            }
        })
    )

    console.log(`Wrote winner ${winner.ticker} (${winner.pctChange}%) for ${date}`)

    return { date, written: true, ...winner}
}