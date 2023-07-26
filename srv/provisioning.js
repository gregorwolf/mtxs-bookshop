const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom");

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

module.exports = (service) => {
  service.on("UPDATE", "tenant", async (req, next) => {
    LOG.info("UPDATE tenant- Subscription data:", JSON.stringify(req.data));
    await next();
    const uiAppName = "mtxs-bookshop";
    let tenantHost = req.data.subscribedSubdomain + "-" + uiAppName;
    let domain = /\.(.*)/gm.exec(appEnv.app.application_uris[0])[1];
    let tenantURL = "https://" + tenantHost + "." + domain;
    await createRoute(tenantHost, domain, uiAppName);
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

async function createRoute(tenantHost, domain, uiAppName) {
  const cfapi = await cds.connect.to("cfapi");

  const uiappGuid = (
    await cfapi.get(
      `/v3/apps` +
        `?organization_guids=${appEnv.app.organization_id}` +
        `&space_guids=${appEnv.app.space_id}` +
        `&names=${uiAppName}`
    )
  ).resources[0].guid;
  LOG.info("UI App GUID: ", uiappGuid);
  const domainGuid = (await cfapi.get(`/v3/domains?names=${domain}`))
    .resources[0].guid;
  LOG.info("Domain GUID: ", domainGuid);
  const createRoute = await cfapi.post("/v3/routes", {
    host: tenantHost,
    relationships: {
      space: {
        data: {
          guid: appEnv.app.space_id,
        },
      },
      domain: {
        data: {
          guid: domainGuid,
        },
      },
    },
  });
  LOG.info("Route created GUID: ", createRoute.guid);
  const mapRouteToApp = await cfapi.post(
    `/v3/routes/${createRoute.guid}/destinations`,
    {
      destinations: [
        {
          app: {
            guid: uiappGuid,
          },
        },
      ],
    }
  );
  LOG.info("Route mapped to app GUID: ", mapRouteToApp.destinations[0].guid);
}
