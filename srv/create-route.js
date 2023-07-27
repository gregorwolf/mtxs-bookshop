const cds = require("@sap/cds");
const LOG = cds.log("create-route");

const executeHttpRequest =
  require("@sap-cloud-sdk/http-client").executeHttpRequest;
const destinationSelectionStrategies =
  require("@sap-cloud-sdk/connectivity").DestinationSelectionStrategies;

const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();

async function createRouteCAP(tenantHost, domain, uiAppName) {
  const cfapi = await cds.connect.to("cfapi");

  let urlFindRoute =
    `/v3/routes?organization_guids=${appEnv.app.organization_id}` +
    `&space_guids=${appEnv.app.space_id}` +
    `&hosts=${tenantHost}`;
  LOG.info("urlFindRoute", urlFindRoute);
  const routeGetResult = await cfapi.get(urlFindRoute);
  const routeGuid = routeGetResult?.resources[0].guid;
  LOG.info("Route GUID: ", routeGuid);
  if (routeGuid) {
    LOG.info("Route already exists");
    return;
  }

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

  const uiAppGuid = (
    await cfapi.get(
      `/v3/apps` +
        `?organization_guids=${appEnv.app.organization_id}` +
        `&space_guids=${appEnv.app.space_id}` +
        `&names=${uiAppName}`
    )
  ).resources[0].guid;
  LOG.info("UI App GUID: ", uiAppGuid);

  const mapRouteToApp = await cfapi.post(
    `/v3/routes/${createRoute.guid}/destinations`,
    {
      destinations: [
        {
          app: {
            guid: uiAppGuid,
          },
        },
      ],
    }
  );
  LOG.info("Route mapped to app GUID: ", mapRouteToApp.destinations[0].guid);
}

async function createRouteCloudSDK(tenantHost, domain, uiAppName) {
  let routeGetResult = {};
  try {
    let urlFindRoute =
      `/v3/routes?organization_guids=${appEnv.app.organization_id}` +
      `&space_guids=${appEnv.app.space_id}` +
      `&hosts=${tenantHost}`;
    LOG.info("urlFindRoute", urlFindRoute);
    routeGetResult = await executeHttpRequest(
      {
        destinationName: "CFAPI",
        selectionStrategy: destinationSelectionStrategies.alwaysProvider,
      },
      {
        method: "get",
        url: urlFindRoute,
        params: {},
      }
    );
  } catch (error) {
    LOG.error("Error message: " && error.message);
  }

  const routeGuid = routeGetResult?.data?.resources[0].guid;
  LOG.info("Route GUID: ", routeGuid);
  if (routeGuid) {
    LOG.info("Route already exists");
    return;
  }

  let domainGetResult = {};
  try {
    let urlFindDomain = `/v3/domains?names=${domain}`;
    LOG.info("urlFindDomain", urlFindDomain);
    domainGetResult = await executeHttpRequest(
      {
        destinationName: "CFAPI",
        selectionStrategy: destinationSelectionStrategies.alwaysProvider,
      },
      {
        method: "get",
        url: urlFindDomain,
        params: {},
      }
    );
  } catch (error) {
    LOG.error("Error message: " && error.message);
  }

  const domainGuid = domainGetResult?.data?.resources[0].guid;
  LOG.info("Domain GUID: ", domainGuid);

  try {
    createRouteResult = await executeHttpRequest(
      {
        destinationName: "CFAPI",
        selectionStrategy: destinationSelectionStrategies.alwaysProvider,
      },
      {
        method: "post",
        url: "/v3/routes",
        params: {},
        data: {
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
        },
      }
    );
    LOG.info("Route created GUID: ", createRouteResult.data.guid);

    let urlFindApp =
      `/v3/apps` +
      `?organization_guids=${appEnv.app.organization_id}` +
      `&space_guids=${appEnv.app.space_id}` +
      `&names=${uiAppName}`;
    LOG.info("urlFindApp", urlFindApp);
    let appGetResult = await executeHttpRequest(
      {
        destinationName: "CFAPI",
        selectionStrategy: destinationSelectionStrategies.alwaysProvider,
      },
      {
        method: "get",
        url: urlFindApp,
        params: {},
      }
    );
    const uiAppGuid = appGetResult?.data?.resources[0].guid;
    LOG.info("UI App GUID: ", uiAppGuid);

    mapRouteToAppResult = await executeHttpRequest(
      {
        destinationName: "CFAPI",
        selectionStrategy: destinationSelectionStrategies.alwaysProvider,
      },
      {
        method: "post",
        url: `/v3/routes/${createRouteResult.data.guid}/destinations`,
        params: {},
        data: {
          destinations: [
            {
              app: {
                guid: uiAppGuid,
              },
            },
          ],
        },
      }
    );
    LOG.info(
      "Route mapped to app GUID: ",
      mapRouteToAppResult.data.destinations[0].guid
    );
  } catch (error) {
    LOG.error("Error message: " && error.message);
  }
}

module.exports = { createRouteCAP, createRouteCloudSDK };
