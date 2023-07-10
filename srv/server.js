const cds = require("@sap/cds");
// https://cap.cloud.sap/docs/node.js/cds-log#configuring-log-levels
const LOG = cds.log("mtxs-custom");

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

// Currently we have to use sap-cloud-sdk for calling the cf api as using the cap function - only working the first time when deployed
// See: https://answers.sap.com/answers/13913549/view.html
const executeHttpRequest =
  require("@sap-cloud-sdk/http-client").executeHttpRequest;
const destinationSelectionStrategies =
  require("@sap-cloud-sdk/connectivity").DestinationSelectionStrategies;

// Read xsappname using xsenv
const xsenv = require("@sap/xsenv");
xsenv.loadEnv();
const services = xsenv.getServices({
  dest: { tag: "destination" },
});
const dependencies = [];
dependencies.push(services.dest.xsappname);
cds.env.requires["cds.xt.SaasProvisioningService"] = { dependencies };

async function fillServiceReplacement(req) {
  if (req.data.tenant !== "t0") {
    // Get enviroment variable
    const vcap = JSON.parse(process.env.VCAP_SERVICES);
    let upsName = "";

    if (req.data.metadata) {
      // for SaasProvisioningService
      upsName = req.data.metadata.subscribedSubdomain + "_CS1HDIAdb";
    } else {
      // for CAP deployment service (/-/cds/deployment/subscribe)
      upsName = req.data.tenant + "_CS1HDIAdb";
    }
    // Check if UPS is existing in vcap
    // to be able to test without access to the cf-api
    let upsContent = vcap["user-provided"]?.filter((ups) => {
      ups.name === upsName;
    });
    if (upsContent === undefined || upsContent.length === 0) {
      // Use Cloud Foundry API to read details of UPS
      // Local Test with CF CLI:
      // cf curl "v3/service_instances?type=user-provided&names=anonymous_CS1HDIAdb"
      let upsGetResult = {};
      try {
        let urlFindUps = `/v3/service_instances?organization_guids=${appEnv.app.organization_id}&space_guids=${appEnv.app.space_id}` +
          `&type=user-provided&names=${upsName}`;
        LOG.info("urlFindUps", urlFindUps);
        upsGetResult = await executeHttpRequest(
          {
            destinationName: "CFAPI",
            selectionStrategy: destinationSelectionStrategies.alwaysProvider,
          },
          {
            method: "get",
            url: urlFindUps,
            params: {},
          }
        );
      } catch (error) {
        LOG.error("Error message: " && error.message);
      }

      if (upsGetResult.data.resources[0] === undefined) {
        LOG.error("UPS not found", upsName);
        throw new Error("UPS not found");
      }

      // get credentials for user-provided service above
      upsGuid = upsGetResult.data.resources[0].guid;
      let upsCredentials = {};
      try {
        upsCredentials = await executeHttpRequest(
          {
            destinationName: "CFAPI",
            selectionStrategy: destinationSelectionStrategies.alwaysProvider,
          },
          {
            method: "get",
            url: `/v3/service_instances/${upsGuid}/credentials`,
            params: {},
          }
        );
      } catch (error) {
        LOG.error("Error message: " && error.message);
      }
      upsContent = {
        label: "user-provided",
        name: upsName,
        tags: ["hana"],
        instance_guid: upsGuid,
        instance_name: upsName,
        binding_name: null,
        credentials: upsCredentials.data,
        syslog_drain_url: null,
        volume_mounts: [],
      };
      if (vcap["user-provided"] === undefined) {
        vcap["user-provided"] = [];
      }
      // add it to vcap
      vcap["user-provided"].push(upsContent);
      // set env variable VCAP_SERVICES
      process.env.VCAP_SERVICES = JSON.stringify(vcap);
    }
    process.env.SERVICE_REPLACEMENTS = JSON.stringify([
      {
        key: "ServiceName_1",
        name: "cross-container-service-1",
        service: upsName,
      },
    ]);
    LOG.debug("SERVICE_REPLACEMENTS", process.env.SERVICE_REPLACEMENTS);
  }
}

cds.on("served", () => {
  LOG.debug("CDS served");
  const { "cds.xt.ModelProviderService": mps } = cds.services;
  const { "cds.xt.DeploymentService": ds } = cds.services;

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
});
