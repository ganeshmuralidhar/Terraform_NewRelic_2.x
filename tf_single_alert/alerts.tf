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

data "newrelic_entity" "app_name" {
  name = "petclinic-java"
  type = "APPLICATION"
  domain = "APM"
}

# Create an alert policy
resource "newrelic_alert_policy" "tf_alert_policy_as_code" {
  name = "TF-Alerts-As-Code-Policy"
  incident_preference = "PER_POLICY"
}

# Add an alert condition - Appdex
resource "newrelic_alert_condition" "tf_alert_condition_appdex" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-Appdex"
  type        = "apm_app_metric"
  condition_scope = "application"
  entities    = [data.newrelic_entity.app_name.application_id]
  metric      = "apdex"
  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }
}

# Add an alert condition - Latency
resource "newrelic_alert_condition" "tf_alert_condition_latency" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-Latency"
  type        = "apm_app_metric"
  condition_scope = "application"
  entities    = [data.newrelic_entity.app_name.application_id]
  metric      = "response_time_background"
  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "0.5"
    time_function = "all"
  }
}

# Add an alert condition - Error Rate
resource "newrelic_alert_condition" "tf_alert_condition_error_rate" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-ErrorRate"
  type        = "apm_app_metric"
  condition_scope = "application"
  entities    = [data.newrelic_entity.app_name.application_id]
  metric      = "error_percentage"
  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "10"
    time_function = "all"
  }
}

# Add an alert condition - Throughput
resource "newrelic_alert_condition" "tf_alert_condition_throughput" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-Throughput"
  type        = "apm_app_metric"
  condition_scope = "application"
  entities    = [data.newrelic_entity.app_name.application_id]
  metric      = "throughput_background"
  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "5"
    time_function = "all"
  }
}

# Add an alert condition - Infra CPU
resource "newrelic_infra_alert_condition" "tf_alert_condition_infra_cpu" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-CPU"
  type        = "infra_metric"
  event       = "SystemSample"
  select      = "cpuPercent"
  comparison  = "above"
  where       = "(hostname LIKE '%web-server%')"
  critical {
    duration      = 5
    value         = 90
    time_function = "all"
  }
  warning {
    duration      = 10
    value         = 80
    time_function = "all"
  }
}

# Add an alert condition - Infra Down
resource "newrelic_infra_alert_condition" "tf_alert_condition_infra_down" {
  policy_id = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  name        = "TF-Alerts-As-Code-Condition-HostDown"
  type        = "infra_host_not_reporting"
  where       = "(hostname LIKE '%web-server%')"
  critical {
    duration = 5
  }
}

# Add a notification channel
resource "newrelic_alert_channel" "tf_alert_email" {
  name = "TF-Alerts-As-Code-Notification-Channel-Email"
  type = "email"

  config {
    recipients              = "gnarasimhadevara@newrelic.com"
    include_json_attachment = "false"
  }
}

# Link the above notification channel to your policy
resource "newrelic_alert_policy_channel" "tf_alert_email" {
  policy_id  = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
  channel_ids = [
    "${newrelic_alert_channel.tf_alert_email.id}"
  ]
}

output "alert_id" {
  value = "${newrelic_alert_policy.tf_alert_policy_as_code.id}"
}
