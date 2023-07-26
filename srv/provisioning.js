const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom");

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

const { createRouteCAP, createRouteCloudSDK } = require("./create-route");

module.exports = (service) => {
  service.on("UPDATE", "tenant", async (req, next) => {
    LOG.info("UPDATE tenant- Subscription data:", JSON.stringify(req.data));
    await next();
    const uiAppName = "mtxs-bookshop";
    let tenantHost = req.data.subscribedSubdomain + "-" + uiAppName;
    let domain = /\.(.*)/gm.exec(appEnv.app.application_uris[0])[1];
    let tenantURL = "https://" + tenantHost + "." + domain;

    if (process.env?.CREATE_ROUTE === "SDK") {
      await createRouteCloudSDK(tenantHost, domain, uiAppName);
    } else {
      await createRouteCAP(tenantHost, domain, uiAppName);
    }
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
