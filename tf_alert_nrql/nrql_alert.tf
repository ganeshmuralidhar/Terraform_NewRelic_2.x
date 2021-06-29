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
  #admin_api_key = "REPLACE HERE"  ----- DONT NEED THIS ANYMORE -----
  account_id = "3029157"
  region = "US"
}

data "newrelic_entity" "app_name" {
  name = "petclinic-java"
  type = "APPLICATION"
  domain = "APM"
}

# Create an alert policy
resource "newrelic_alert_policy" "tf_nrql_alert_policy_as_code" {
  name = "TF-NRQL-Alerts-As-Code-Policy"
  incident_preference = "PER_POLICY"
}

# Add an alert condition - Appdex
resource "newrelic_nrql_alert_condition" "tf_nrql_alert_condition_appdex" {
  account_id                   = "3029157"
  policy_id                    = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  type                         = "static"
  name                         = "TF-NRQL-Alerts-As-Code-Condition-Appdex"
  description                  = "Alert when Apdex score drop below 0.9 for more than 5 mins"
  enabled                      = true
  value_function               = "single_value"
  violation_time_limit_seconds = 1800

  nrql {
    query             = "SELECT apdex(`apm.service.apdex`) FROM Metric WHERE appName LIKE 'petclinic-java'"
    evaluation_offset = 3
  }

  critical {
    operator              = "below"
    threshold             = 0.8
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "below"
    threshold             = 0.9
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# Add an alert condition - Latency
resource "newrelic_nrql_alert_condition" "tf_nrql_alert_condition_latency" {
  account_id                   = "3029157"
  policy_id                    = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  type                         = "static"
  name                         = "TF-NRQL-Alerts-As-Code-Condition-Latency"
  description                  = "Alert when Latency increased above 1 sec for more than 5 mins"
  enabled                      = true
  value_function               = "single_value"
  violation_time_limit_seconds = 1800

  nrql {
    query             = "SELECT average(`apm.service.transaction.duration`) FROM Metric WHERE appName LIKE 'petclinic-java'"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 0.75
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# Add an alert condition - Error Rate
resource "newrelic_nrql_alert_condition" "tf_nrql_alert_condition_error_rate" {
  account_id                   = "3029157"
  policy_id                    = "${newrelic_alert_policy.tf_nrql_alert_policy_as_code.id}"
  type                         = "static"
  name                         = "TF-NRQL-Alerts-As-Code-Condition-ErrorRate"
  description                  = "Alert when Error Rate spikes beyond 10% for more than 5 mins"
  enabled                      = true
  value_function               = "single_value"
  violation_time_limit_seconds = 1800

  nrql {
    query             = "SELECT percentage(count(*), WHERE error is true) AS 'Error rate' FROM Transaction WHERE appName LIKE 'petclinic-java'"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 10
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# Add an alert condition - Throughput
resource "newrelic_nrql_alert_condition" "tf_nrql_alert_condition_throughput" {
  account_id                   = "3029157"
  policy_id                    = "${newrelic_alert_policy.tf_nrql_alert_policy_as_code.id}"
  type                         = "static"
  name                         = "TF-NRQL-Alerts-As-Code-Condition-Throughput"
  description                  = "Alert when Throughput drops below 0.5 for more than 5 mins"
  enabled                      = true
  value_function               = "single_value"
  violation_time_limit_seconds = 1800

  nrql {
    query             = "SELECT rate(count(apm.service.transaction.duration), 1 minute) FROM Metric WHERE appName LIKE 'petclinic-java'"
    evaluation_offset = 3
  }

  critical {
    operator              = "below"
    threshold             = 0.5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "below"
    threshold             = 0.75
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

# Add an alert condition - Infra CPU
resource "newrelic_nrql_alert_condition" "tf_nrql_alert_condition_infra_cpu" {
  account_id                   = "3029157"
  policy_id                    = "${newrelic_alert_policy.tf_nrql_alert_policy_as_code.id}"
  type                         = "static"
  name                         = "TF-NRQL-Alerts-As-Code-Condition-Infra-CPU"
  description                  = "Alert when CPU Utilization on host spikes beyond 90% for more than 5 mins"
  enabled                      = true
  value_function               = "single_value"
  violation_time_limit_seconds = 1800

  nrql {
    query             = "SELECT average(host.cpuPercent) FROM Metric WHERE host.hostname LIKE '%'"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}


# Add a notification channel
resource "newrelic_alert_channel" "tf_nrql_alert_email" {
  name = "TF-NRQL-Alerts-As-Code-Notification-Channel-Email"
  type = "email"

  config {
    recipients              = "gnarasimhadevara@newrelic.com"
    include_json_attachment = "false"
  }
}

# Link the above notification channel to your policy
resource "newrelic_alert_policy_channel" "tf_nrql_alert_email" {
  policy_id  = "${newrelic_alert_policy.tf_nrql_alert_policy_as_code.id}"
  channel_ids = [
    "${newrelic_alert_channel.tf_alert_email.id}"
  ]
}

output "alert_id" {
  value = "${newrelic_alert_policy.tf_nrql_alert_policy_as_code.id}"
}
