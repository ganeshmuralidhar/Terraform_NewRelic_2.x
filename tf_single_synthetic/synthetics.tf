terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "2.22.1"
    }
  }
}

provider "newrelic" {
  api_key = var.APIKEY
  account_id = var.ACCOUNTID
  region = "US"
}

resource "newrelic_synthetics_monitor" "tf_synthetic_monitor_as_code" {
  name = "TF-Demo-Synthetic-Monitor-As-Code"
  type = "BROWSER"
  frequency = 1
  status = "ENABLED"
  locations = ["AWS_US_EAST_1", "AWS_US_EAST_2"]

  uri                       = "<URL>"
  validation_string         = "<Validation Check>"
  verify_ssl                = false
}

output "synthetic_monitor_id" {
  value = "${newrelic_synthetics_monitor.tf_synthetic_monitor_as_code.id}"
}
