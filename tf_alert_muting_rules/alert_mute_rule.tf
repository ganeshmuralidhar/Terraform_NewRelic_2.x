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

#Get alert policy created
data "newrelic_alert_policy" "tf_alert_policy_as_code" {
  name = "TF-Alerts-As-Code-Policy"
}

resource "newrelic_alert_muting_rule" "tf_muting_rule" {
    name = "TF-MuteRule-As-Code-Condition-CPUPercent"
    enabled = true
    description = "Mute the alerts on CPU Percentage and Latency for 2 AM to 5 PM every Monday and Wednesday"
    condition {
        conditions {
            attribute   = "policyId"
            operator    = "EQUALS"
            values      = [data.newrelic_alert_policy.tf_alert_policy_as_code.id]
        }
        conditions {
            attribute   = "conditionName"
            operator    = "EQUALS"
            values      = ["TF-Alerts-As-Code-Condition-Latency"]
        }
        operator = "AND"
    }
    schedule {
      start_time = "2021-07-01T02:00:00"
      end_time = "2021-07-01T04:00:00"
      time_zone = "Asia/Kolkata"
      repeat = "WEEKLY"
      weekly_repeat_days = ["MONDAY", "WEDNESDAY"]
      end_repeat = "2021-12-31T04:00:00"
      #repeat_count = 42
    }
}

output "muting_rule_id" {
  value = "${newrelic_alert_muting_rule.tf_muting_rule.id}"
}
