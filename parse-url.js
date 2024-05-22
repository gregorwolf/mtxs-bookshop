//
const SUBSCRIPTION_URL =
  "https://${tenant_subdomain}-60e3b81etrial-dev-mtxs-test.cfapps.us10-001.hana.ondemand.com";
// Parse the URL and extract the tenant subdomain
const url = new URL(SUBSCRIPTION_URL);
// Get the domain from the URL
let domain = /\.(.*)/gm.exec(url.host)[1];

console.log(domain);
