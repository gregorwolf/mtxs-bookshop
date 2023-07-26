const cds = require("@sap/cds");
// https://cap.cloud.sap/docs/node.js/cds-log#configuring-log-levels
const LOG = cds.log("mtxs-custom");

// Read xsappname of services using xsenv
const xsenv = require("@sap/xsenv");
xsenv.loadEnv();
const services = xsenv.getServices({
  dest: { tag: "destination" },
});
// fill dependencies for cds.env.requires
const dependencies = [];
dependencies.push(services.dest.xsappname);
cds.env.requires["cds.xt.SaasProvisioningService"] = { dependencies };

async function fillServiceReplacement(req) {
  if (process.env?.CREATE_ROUTE === "SDK") {
    const {
      fillServiceReplacementCloudSDK,
    } = require("./service-replacement-cloud-sdk");
    return fillServiceReplacementCloudSDK(req);
  } else {
    const { fillServiceReplacementCAP } = require("./service-replacement-cap");
    return fillServiceReplacementCAP(req);
  }
}

cds.on("served", () => {
  LOG.debug("CDS served");
  const { "cds.xt.ModelProviderService": mps } = cds.services;
  const { "cds.xt.DeploymentService": ds } = cds.services;
  const { "cds.xt.SaasProvisioningService": provisioning } = cds.services;

  ds.before("subscribe", async (req) => {
    LOG.info("subscribe");
    await fillServiceReplacement(req);
  });

  ds.before("upgrade", async (req) => {
    LOG.info("upgrade");
    await fillServiceReplacement(req);
  });

  mps.after("getCsn", (csn) => {
    LOG.info("getCsn");
  });

  if (provisioning) {
    let tenantProvisioning = require("./provisioning");
    provisioning.prepend(tenantProvisioning);
  } else {
    LOG.info("There is no service, therefore does not serve multitenancy!");
  }
});
