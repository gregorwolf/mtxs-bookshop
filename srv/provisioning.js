const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom-provisioning");
const xsenv = require("@sap/xsenv");
xsenv.loadEnv();

module.exports = (service) => {
  service.on("UPDATE", "tenant", async (req, next) => {
    LOG.info("Subscription data:", JSON.stringify(req.data));
    const Automator = require("./utils/automator");

    let tenantSubdomain = req.data.subscribedSubdomain;
    let tenant = req.data.subscribedTenantId;
    let tenantSubaccountId = req.data.subscribedSubaccountId;
    const tenantHost = tenantSubdomain;
    const tenantURL = `https://${tenantHost}${process.env.tenantSeparator}${process.env.appDomain}`;

    await next();
    // Trigger tenant broker deployment on background
    cds.spawn({ tenant: tenant }, async (tx) => {
      try {
        let automator = new Automator();
        await automator.deployTenantArtifacts(
          tenantSubdomain,
          tenantSubaccountId
        );
      } catch (error) {
        LOG.error(
          "Error: Automation skipped because of error during subscription"
        );
        LOG.error(`Error: ${error.message}`);
      }
    });
    return tenantURL;
  });

  service.on("DELETE", "tenant", async (req, next) => {
    const Automator = require("./utils/automator");
    let tenantSubdomain = req.data.subscribedSubdomain;
    let tenantSubaccountId = req.data.subscribedSubaccountId;
    LOG.info("Unsubscribe Data: ", JSON.stringify(req.data));
    await next();
    try {
      let automator = new Automator();
      await automator.undeployTenantArtifacts(
        tenantSubaccountId,
        tenantSubdomain
      );
    } catch (error) {
      LOG.error(
        "Error: Automation skipped because of error during unsubscription"
      );
      LOG.error(`Error: ${error.message}`);
    }
    return req.data.subscribedTenantId;
  });

  service.on("upgradeTenant", async (req, next) => {
    await next();
    const { instanceData, deploymentOptions } = cds.context.req.body;
    LOG.info(
      "UpgradeTenant: ",
      req.data.subscribedTenantId,
      req.data.subscribedSubdomain,
      instanceData,
      deploymentOptions
    );
  });
};
