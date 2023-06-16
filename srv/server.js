const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom");

cds.on("served", () => {
  const { "cds.xt.ModelProviderService": mps } = cds.services;
  const { "cds.xt.DeploymentService": ds } = cds.services;
  ds.before("subscribe", (_, req) => {
    LOG.info("subscribe");
  });
  ds.before("upgrade", (req) => {
    LOG.info("upgrade");
  });
  mps.after("getCsn", (csn) => {
    LOG.info("getCsn");
  });
});
