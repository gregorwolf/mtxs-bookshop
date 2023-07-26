const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom");

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

module.exports = (service) => {
  service.on("UPDATE", "tenant", async (req, next) => {
    LOG.info("UPDATE tenant- Subscription data:", JSON.stringify(req.data));
    await next();
    let tenantHost = req.data.subscribedSubdomain + "-" + "mtxs-bookshop";
    let domain = /\.(.*)/gm.exec(appEnv.app.application_uris[0])[1];
    let tenantURL = "https://" + tenantHost + "." + domain;
    return tenantURL;
  });

  service.on("DELETE", "tenant", async (req, next) => {
    LOG.info("DELETE tenant");
    await next();
    return req.data.subscribedTenantId;
  });

  service.on("upgradeTenant", async (req, next) => {
    LOG.info("upgradeTenant");
    await next();
  });
};
