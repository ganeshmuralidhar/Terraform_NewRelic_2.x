terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "2.22.1"
    }
  }
}

provider "newrelic" {
  api_key = "YOUR API KEY HERE"
  #admin_api_key = "REPLACE HERE"  ----- DONT NEED THIS ANYMORE -----
  account_id = "YOUR ACCOUNT ID HERE"
  region = "US"
}

resource "newrelic_one_dashboard" "tf_dashboard_as_code" {
  name = "TF-Demo-Dashboards-As-Code"

  page {
    name = "End User Experience & UpTime"

    widget_billboard {
      title = "End User Response Time Summary (Last 30 mins)"
      row = 1
      column = 1
      width = 9
      nrql_query {
        query       = "SELECT average(durationBlocked + durationConnect + durationDNS + durationWait) as 'First Byte', average(firstPaint) as 'First Paint', average(firstContentfulPaint) as 'First Contentful Paint', average(onPageLoad) as 'Page Load' FROM SyntheticRequest SINCE 30 minutes ago"
      }
    }

    widget_area {
      title = "End User Response Time BreakDown"
      row = 2
      column = 1
      width = 12
      nrql_query {
        query       = "SELECT average(durationBlocked + durationConnect + durationDNS + durationWait) as 'First Byte', average(firstPaint) as 'First Paint', average(firstContentfulPaint) as 'First Contentful Paint', average(onPageLoad) as 'Page Load' FROM SyntheticRequest TIMESERIES"
      }
    }

    widget_billboard {
      title = "UpTime"
      row = 1
      column = 10
      width = 3
      nrql_query {
        query       = "FROM SyntheticCheck SELECT 100-percentage(count(*), WHERE result = 'FAILED') as UpTime"
      }
    }

widget_billboard {
  title = "Success Count"
  row = 3
  column = 1
  width = 5
  nrql_query {
    query       = "SELECT count(*) FROM SyntheticCheck WHERE monitorId = '1f6fca46-6a21-4568-8ac7-9e0dd7600de7' and result = 'SUCCESS' FACET locationLabel"
  }
}

widget_billboard {
  title = "Failure Count"
  row = 3
  column = 6
  width = 5
  warning = 2
  critical = 5
  nrql_query {
    query       = "SELECT count(*) FROM SyntheticCheck WHERE monitorId = '1f6fca46-6a21-4568-8ac7-9e0dd7600de7' and result = 'FAILED' FACET locationLabel"
  }
}
    widget_markdown {
      title = "Dashboard Note"
      row    = 3
      column = 11
      width = 2
      text = "### Helpful Links\n\n* [New Relic One](https://one.newrelic.com)\n* [Developer Portal](https://developer.newrelic.com)"
    }
  }

  page {
    name = "App Performance (Service Level)"

    widget_area {
      title = "Transaction Response Time by Transaction"
      row = 1
      column = 1
      width = 6
      nrql_query {
        query       = "SELECT average(duration) from Transaction FACET name TIMESERIES 1 minute"
      }
    }
    widget_area {
      title = "Throughput Per Hour by Transaction"
      row = 1
      column = 7
      width = 6
      nrql_query {
        query       = "SELECT count(*) FROM Transaction FACET name TIMESERIES 1 minute"
      }
    }
    widget_area {
      title = "Error by Transaction"
      row = 2
      column = 1
      width = 6
      nrql_query {
        query       = "SELECT percentage(count(*), WHERE error is true) FROM Transaction FACET name TIMESERIES 1 minute"
      }
    }

    widget_pie {
      title = "Requests per minute, by Transaction"
      row = 2
      column = 7
      width = 6
      nrql_query {
        query       = "FROM Transaction SELECT rate(count(*), 1 minute) FACET name"
      }
    }

  }

}

output "dashboard_id" {
  value = "${newrelic_one_dashboard.tf_dashboard_as_code.id}"
}
