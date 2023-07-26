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

async function createRouteCloudSDK(tenantHost, domain, uiAppName) {
  let appGetResult = {};
  try {
    let urlFindApp =
      `/v3/apps` +
      `?organization_guids=${appEnv.app.organization_id}` +
      `&space_guids=${appEnv.app.space_id}` +
      `&names=${uiAppName}`;
    LOG.info("urlFindApp", urlFindApp);
    appGetResult = await executeHttpRequest(
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
  } catch (error) {
    LOG.error("Error message: " && error.message);
  }

  const uiappGuid = appGetResult?.data?.resources[0].guid;
  LOG.info("UI App GUID: ", uiappGuid);

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
                guid: uiappGuid,
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
