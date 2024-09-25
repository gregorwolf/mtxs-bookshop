const cds = require("@sap/cds");
const LOG = cds.log("flp-content-exposure-service");
const flpContent = require("./flp-content.json");
module.exports = cds.service.impl(async function () {
  /*
  const flpContentExposureService = await cds.connect.to(
    "FlpContentExposureService"
  );
  const { entities } = flpContentExposureService.entities;
  */
  this.on("READ", "entities", async (req, next) => {
    LOG.info("READ entities");
    return flpContent;
  });
});
