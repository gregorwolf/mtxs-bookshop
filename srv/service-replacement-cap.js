const cds = require("@sap/cds");
// https://cap.cloud.sap/docs/node.js/cds-log#configuring-log-levels
const LOG = cds.log("service-replacement-cap");

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

async function fillServiceReplacementCAP(req) {
  if (req.data.tenant !== "t0") {
    // Get enviroment variable
    const vcap = JSON.parse(process.env.VCAP_SERVICES);
    let upsName = "";
    const cfapi = await cds.connect.to("cfapi");

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
      upsGetResult = await cfapi.get(
        `/v3/service_instances?organization_guids=${appEnv.app.organization_id}&space_guids=${appEnv.app.space_id}` +
          `&type=user-provided&names=${upsName}`
      );

      if (upsGetResult.resources[0] === undefined) {
        LOG.error("UPS not found", upsName);
        throw new Error("UPS not found");
      }

      // get credentials for user-provided service above
      upsGuid = upsGetResult.resources[0].guid;
      upsCredentials = await cfapi.get(
        `/v3/service_instances/${upsGuid}/credentials`
      );
      upsContent = {
        label: "user-provided",
        name: upsName,
        tags: ["hana"],
        instance_guid: upsGuid,
        instance_name: upsName,
        binding_name: null,
        credentials: upsCredentials,
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

module.exports = { fillServiceReplacementCAP };
