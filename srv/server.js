const cds = require("@sap/cds");
// https://cap.cloud.sap/docs/node.js/cds-log#configuring-log-levels
const LOG = cds.log("mtxs-custom");
const { config } = require("@cap-js-community/event-queue");

// read from environment variable EVENT_PROCESSING_TENANTS
const tenants = JSON.parse(process.env.EVENT_PROCESSING_TENANTS || "[]");
LOG.info(`Tenants to be processed on this instance: ${tenants}`);
async function checkIfTenantShouldBeProcessedOnInstance(tenantId) {
  LOG.info(
    `Checking if tenant ${tenantId} should be processed on this instance`
  );
  if (tenants.includes(tenantId)) {
    LOG.info(`Tenant ${tenantId} should be processed on this instance`);
    return true;
  } else {
    LOG.info(`Tenant ${tenantId} should not be processed on this instance`);
    return false;
  }
}
// Define a callback function to determine if a tenant's events should be processed
config.tenantIdFilterEventProcessing = async (tenantId) => {
  // Replace with your custom logic to decide whether to process the tenant
  return await checkIfTenantShouldBeProcessedOnInstance(tenantId);
};

// const fesr = require("@sap/fesr-to-otel-js");

// Read xsappname of services using xsenv
const xsenv = require("@sap/xsenv");
const e = require("express");
xsenv.loadEnv();
if (xsenv.readCFServices() === undefined) {
  LOG.info("starting locally");
} else {
  const services = xsenv.getServices({
    dest: { tag: "destination" },
    connectivity: { tag: "connectivity" },
    html5rt: { tag: "html5appsrepo" },
    launchpad: { tag: "launchpad" },
    theming: { tag: "sap-theming" },
  });
  // fill dependencies for cds.env.requires
  const dependencies = [];
  dependencies.push(services.dest.xsappname);
  dependencies.push(services.connectivity.xsappname);
  dependencies.push(services.html5rt.uaa.xsappname);
  dependencies.push(services.launchpad.uaa.xsappname);
  dependencies.push(services.theming.uaa.xsappname);
  cds.env.requires["cds.xt.SaasProvisioningService"] = { dependencies };
}
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

/*
cds.on("bootstrap", async (app) => {
  fesr.registerFesrEndpoint(app);
});
*/

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
