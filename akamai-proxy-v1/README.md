# Akamai property Terraform example

This repository contains an example Terraform project of a Property (a site) on the Akamai Dynamic Site Acceleration platform (Akamai CDN). You can use it to deploy a property on Akamai as infrastructure-as-code and test the [Fingerprint Akamai Proxy integration](https://github.com/fingerprintjs/fingerprint-pro-akamai-integration-property-rules).

## Prerequisites

1. Get access to the Akamai Control Center.
2. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform) on your machine. Run your terminal as "rosetta" if you are on a Mac M1 machine.
3. Have a public website you want to host on Akamai available on a dedicated origins. For example, throw an `index.html` file on [Cloudflare pages](https://pages.cloudflare.com/) and make it available on `origin-akamai.your-website.com`. You can then point `akamai.your-website.com` to Akamai Akamai EdgeSuite.

## Getting started

1. Clone this repository.
2. [Create an Akamai API client and download your credentials](https://techdocs.akamai.com/terraform/docs/overview#create-a-basic-api-client) into a `.edgerc` file. This file is referenced in provider configuration inside [main.tf](/main.tf).
3. Open [terraform.tfvars](./terraform.tfvars) file and replace values with your own.
   - `domain` is the Akamai property domain
   - `origin` is your content's domain, you may use `origin-akamai.cfi-fingerprint.com` if you like
   - `contact_email` may be your work email
4. Run `terraform init`.
5. Run `terraform plan`.
6. Run `terraform apply`. Enter 'yes' as the value. This will take around 10 mins to complete. The property creation is fast, but activation takes a long time. The output will look like this:

```bash
Plan: 1 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

akamai_property.property: Modifying... [id=prp_985545]
akamai_property.property: Modifications complete after 8s [id=prp_985545]
akamai_property_activation.activation: Creating...
akamai_property_activation.activation: Still creating... [10s elapsed]
akamai_property_activation.activation: Still creating... [20s elapsed]
akamai_property_activation.activation: Still creating... [30s elapsed]
akamai_property_activation.activation: Still creating... [40s elapsed]
akamai_property_activation.activation: Still creating... [11m50s elapsed]
...
akamai_property_activation.activation: Still creating... [12m0s elapsed]
akamai_property_activation.activation: Creation complete after 12m5s [id=prp_985545:PRODUCTION]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

7. Create a CNAME record for your domain that points to `${your-domain}.edgesuite.net`

After CNAME record is published and your property is activated, your domain should work.

## Enable HTTPS

Note that you don't have to enable HTTPS to use the property.

Log in to Akamai Control Panel, and click **Certificates** on the left menu. Click **Create New Certificate** to create a new DV certificate and follow instructions.
