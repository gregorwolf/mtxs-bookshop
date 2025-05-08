const cds = require("@sap/cds");
const { Worker, isMainThread } = require("node:worker_threads");
// https://cap.cloud.sap/docs/node.js/cds-log#configuring-log-levels
const LOG = cds.log("mtxs-custom");
const { config } = require("@cap-js-community/event-queue");

/*
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
*/
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
    jobscheduler: { tag: "jobscheduler" },
  });
  LOG.info("Services found: ", services);
  // fill dependencies for cds.env.requires
  const dependencies = [];
  dependencies.push(services.dest.xsappname);
  dependencies.push(services.connectivity.xsappname);
  dependencies.push(services.html5rt.uaa.xsappname);
  dependencies.push(services.launchpad.uaa.xsappname);
  dependencies.push(services.theming.uaa.xsappname);
  // when jobscheduler on BTP Trial with plan lite is used and
  // returned as a dependency the subscription update fails with:
  //
  // updateApplicationSubscription failed
  // Error build subscription tree : getServiceDependencyAppId
  // Response from XSUAA invalid: XsuaaApplicationDto(xsappname=jobscheduler
  //
  // Try again after  grant-as-authority-to-apps: jobscheduler is set in xs-security.json
  // No change.
  //
  // In normal BTP subaccount the jobscheduler plan standard is used
  dependencies.push(services.jobscheduler.uaa.xsappname);
  LOG.info("Dependencies: ", dependencies);
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

/*
cds.middlewares.before = [
  cds.middlewares.context(),
  cds.middlewares.trace(),
  // Instruct CAP to select the XSUAA Instance based on the client_id provided in the JWT token
  function before_auth(_, __, next) {
    // Load xsenv
    const xsenv = require("@sap/xsenv");
    xsenv.loadEnv();
    const ctx = cds.context;
    // Parse the JWT token from the Authorization header
    const authHeader = ctx.http.req.headers.authorization;
    if (!authHeader) {
      return next();
    }
    const jwtToken = authHeader.split(" ")[1];
    if (!jwtToken) {
      return next();
    }
    // Parse the JWT token
    const jwt = require("jsonwebtoken");
    const decoded = jwt.decode(jwtToken);
    if (!decoded) {
      return next();
    }
    // Read the client_id from the JWT token
    const clientId = decoded.client_id;
    LOG.info(`Client ID: ${clientId}`);
    // Read bound XSUAA service instances
    const xsuaas = xsenv.getServices({ xsuaa: { label: "xsuaa" } });
    // Find the XSUAA service instance that matches the clientId
    const xsuaa = Object.values(xsuaas).find((xsuaa) => {
      return xsuaa.credentials.clientid === clientId;
    });
    if (!xsuaa) {
      return next();
    }
    // Set the selector to find the correct XSUAA in
    delete cds.env.requires.auth.vcap.name;
    // When clientId contains api
    if (clientId.includes("api")) {
      cds.env.requires.auth.vcap.plan = "broker";
    } else {
      cds.env.requires.auth.vcap.plan = "application";
    }
    next();
  },
  cds.middlewares.auth(),
  cds.middlewares.ctx_model(),
];
*/
// listening
cds.on("listening", () => {
  LOG.info(`Server listening on ${cds.app.server.address().port}`);
  // Start additional instances as worker threads
  if (isMainThread) {
    const worker = new Worker("./node_modules/@sap/cds/bin/cds-serve.js", {
      env: {
        PORT: cds.env.server?.port + 1,
        VCAP_SERVICES: process.env.VCAP_SERVICES,
        VCAP_APPLICATION: process.env.VCAP_APPLICATION,
        CDS_ENV: process.env.CDS_ENV,
        HOME: process.env.HOME,
        CDS_CONFIG: JSON.stringify({
          eventQueue: {
            registerAsEventProcessor: true,
          },
        }),
      },
    });
    LOG.info("Worker thread started");
  }
});
