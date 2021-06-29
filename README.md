## Observability as Code with Terraform and New Relic

### Technical Overview

This is a consolidated best practice guide available for anyone who is interested to use Terraform with New Relic.

It’s possible to treat configurations as code with New Relic, called “**Observability as code**”, adopting infrastructure as code for your monitoring and alerting environment.

These materials were prepared as part of the Observability Series with New Relic. Further details about implementating Terraform with New Relic can be found in the the **Additional Links** section.

#### Recommended steps to start with Terraform and New Relic

1. Start by exploring available online resources.
2. Review your existing deployment pipeline.
3. Determine which dynamic variables you could pass into Terraform.
4. Work through the design considerations with Terraform and New Relic.
5. Experiment with a one simple Terraform module before adding more.
6. Work towards Terraform's recommendated module structure - main, output, and variables.

#### Recomended modules to start with Terraform and New Relic

0. Use terraform init -upgrade to get the latest New Relic Provider
1. Start with a basic example > small modules = tf_single_synthetic or tf_single_alert
2. Build dashboards based on Google SRE 4 Golden Signals and alerts with NRQL > tf_alert_nrql + tf_single_dashboard
3. Experiment on alert muting rules and other interesting resources > tf_alert_muting_rules

## Notes

The provided tf files **WILL NOT** work out of the box.

Look for **vars.xxxx** in the code and please do the following:

-   Create a variable.tf file in the same folder as .tf and add variables for API key and Account ID (and any other variables you may want)
  -   api_key > Your New Relic [personal API](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key) key.
  -   account_id > Your New Relic [account ID](https://docs.newrelic.com/docs/accounts/install-new-relic/account-setup/account-id).
-   region > Your New Relic account's [data center region](https://docs.newrelic.com/docs/using-new-relic/welcome-new-relic/get-started/our-eu-us-region-data-centers) (US or EU).
-   apm_appname > Your designated [application name](https://docs.newrelic.com/docs/agents/manage-apm-agents/app-naming/name-your-application).
-   email > Your preferred [email address](https://docs.newrelic.com/docs/alerts/new-relic-alerts/managing-notification-channels/view-or-update-user-email-channels).

Many [Terraform recommeded practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html) are applicable especially when it comes to encrypting [New Relic API keys](https://www.terraform.io/docs/state/sensitive-data.html).

When using Terraform in your CI/CD pipeline, we recommend setting your environment variables within your platform's secrets management. Each platform, such as GitHub or CircleCI, has their own way of managing secrets and environment variables, so you will need to refer to your vendor's documentation for implemenation details.

## Addtional Links

From Infrastructure-as-Code to Observability-as-Code (APAC) [Webinar](https://newrelic.com/resources/webinars/infrastructure-as-code-observability-01-07-20).

Materials, references, and the slide from the [Recording](https://drive.google.com/file/d/1xPpQ9OQaWUAJRFWWoSWKQb0_qNWhVEdy/view?usp=sharing).

New Relic Terraform Official [Provider Page](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs).

New Relic Terraform Official [Github Page](https://github.com/newrelic/terraform-provider-newrelic).

New Relic Dashboard in [Terraform](https://www.terraform.io/docs/providers/newrelic/r/dashboard.html) and [Supported Visualizations](https://docs.newrelic.com/docs/insights/insights-api/manage-dashboards/insights-dashboard-api#supported).

New Relic Alert [Policy](https://www.terraform.io/docs/providers/newrelic/r/alert_policy.html), [Condition](https://www.terraform.io/docs/providers/newrelic/r/alert_condition.html), and [Channel](https://www.terraform.io/docs/providers/newrelic/r/alert_channel.html).

[Modular Infrastructure Deployments at New Relic with Terraform](https://www.hashicorp.com/resources/modular-infrastructure-deployments-new-relic-terraform)
