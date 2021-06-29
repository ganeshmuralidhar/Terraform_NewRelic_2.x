terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "2.22.1"
    }
  }
}

provider "newrelic" {
  api_key = "NRAK-MZOETQ0IWSEJALFICS20ALSZAC6"
  #admin_api_key = "REPLACE HERE" ----- DONT NEED THIS ANYMORE -----
  account_id = "3029157"
  region = "US"
}

resource "newrelic_synthetics_monitor" "tf_synthetic_monitor_as_code" {
  name = "TF-Demo-Synthetic-Monitor-As-Code"
  type = "BROWSER"
  frequency = 1
  status = "ENABLED"
  locations = ["AWS_US_EAST_1", "AWS_US_EAST_2"]

  uri                       = "http://65.1.226.30:8080/"
  validation_string         = "PetClinic :: a Spring Framework demonstration"
  verify_ssl                = false
}

output "synthetic_monitor_id" {
  value = "${newrelic_synthetics_monitor.tf_synthetic_monitor_as_code.id}"
}
