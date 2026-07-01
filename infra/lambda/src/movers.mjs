import { DynamoDBClient } from "@aws-sdk/client-dynamodb"
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb"

const TABLE_NAME = process.env.TABLE_NAME

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}))

export async function handler() {
    try {
        const res = await ddb.send(
            new QueryCommand({
                TableName: TABLE_NAME, 
                KeyConditionExpression: "PK = :pk",
                ExpressionAttributeValues: { ":pk": "MOVER"},
                ScanIndexForward: false,
                Limit: 7
            })
        )

        const movers = (res.Items || []).map((item) => ({
            date: item.SK,
            ticker: item.ticker,
            pctChange: item.pctChange,
            closePrice: item.closePrice
        }))

        return {
            statusCode: 200,
            headers: { 
                "Content-Type" : "application/json",
                "Cache-Control": "public, max-age=3600, s-maxage=3600",
                "Vary": "Origin"
            },
            body: JSON.stringify(movers)
        }
    } catch (err) {
        console.error("Query failed: ", err)
        return {
            statusCode: 500,
            headers: { 
                "Content-Type" : "application/json",
                "Cache-Control": "no-store"
            },
            body: JSON.stringify({ error: "Failed to fetch movers"})
        }
    }
}