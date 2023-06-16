const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom");

cds.on("served", () => {
  const { "cds.xt.ModelProviderService": mps } = cds.services;
  const { "cds.xt.DeploymentService": ds } = cds.services;

  ds.before("subscribe", async (req) => {
    LOG.info("subscribe");
    const cfapi = await cds.connect.to("cfapi");
    const vcap = JSON.parse(process.env.VCAP_SERVICES);
    const upsName = req.data.tenant + "_CS1HDIAdb";
    // Check if UPS is existing in vcap
    let upsContent = vcap["user-provided"]?.filter((ups) => {
      ups.name === upsName;
    });
    if (upsContent === undefined || upsContent.length === 0) {
      // Use Cloud Foundry API to read details of UPS
      // Local Test with CF CLI:
      // cf curl "v3/service_instances?type=user-provided&names=anonymous_CS1HDIAdb"
      const upsGetResult = await cfapi.get(
        `/v3/service_instances?type=user-provided&names=${upsName}`
      );
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
  });
  ds.before("upgrade", (req) => {
    LOG.info("upgrade");
  });
  mps.after("getCsn", (csn) => {
    LOG.info("getCsn");
  });
});
