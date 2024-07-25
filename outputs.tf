# Output the API Endpoint
output "endpoint_url" {
  value = "${aws_api_gateway_stage.example_stage.invoke_url}/${var.endpoint_path}"
}