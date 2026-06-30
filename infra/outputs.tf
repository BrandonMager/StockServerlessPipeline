output "api_invoke_url" {
    description = "Base URL for the API"
    value = "${aws_apigatewayv2_api.http.api_endpoint}/movers"
}
