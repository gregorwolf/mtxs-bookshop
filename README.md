# MTXS Bookshop

Welcome this Multitenant CAP project using the new MTXS package. The special functionality in this project is the dynamic setting of SERVICE_REPLACEMENTS and VCAP_SERVICES based on a User Provided Service. The credentials of this UPS are retrieved from using the Cloud Foundry API.

It contains these folders and files, following our recommended project layout:

| File or Folder | Purpose                              |
| -------------- | ------------------------------------ |
| `app/`         | content for UI frontends goes here   |
| `db/`          | your domain models and data go here  |
| `srv/`         | your service models and code go here |
| `package.json` | project metadata and configuration   |
| `readme.md`    | this getting started guide           |

## Prerequisites

Before you can test this project you have to fulfill the following prerequisites:

- The project [CS1HDIA](https://github.com/gregorwolf/CS1HDIA) must be deployed to the Cloud Foundry provider subaccount
- You have created a service key for the HDI Container of the CS1HDIA project. Based on this service key you have created a User Provided Service with the schema `<tenant>_CS1HDIAdb` in the provider subaccount.
- The destination CFAPI based on the file `CFAPI` exists in the provider subaccount

## Manual steps needed for Service Broker

### Generate Broker Credentials

1. Navigate into folder `/broker`
2. Run command `npm i` in terminal
3. Run command `npm run init` in terminal
4. Store the generated credentials in a safe place

### Create `.mtaext` file

1. Copy file `cf-service-broker-template.mtaext` to `cf-service-broker-private.mtaext`
2. Copy the hashed broker credentials from your safe place into the `cf-service-broker-private.mtaext` file

### Register broker

Build and deploy the MTAR as described in the next step. After the deployment you can register the broker with:

```sh
 export CF_BROKER_PASSWORD=<broker-password>
cf create-service-broker mtxs-bookshop-broker-dev broker-user <broker-url> --space-scoped
```

- The `broker-url` can be read from e.g. the SAP BTP cockpit by navigating to the broker application in the space where it was deployed.

## Run local with redis

### using redis as a container

To run the project locally with the redis cache you can either start the redis server as a container with the following command:

```bash
docker run -p 6379:6379 --name redis -d redis
```

and add the following to the `.cdsrc-private.json` file in the "requires"."[hybrid]" section:

```json
      "eventqueue-redis-cache": {
        "credentials": {
          "hostname": "127.0.0.1",
          "port": 6379,
          "uri": "redis://127.0.0.1:6379",
          "cluster_mode": false
        }
      }
```

### using the redis service from the provider subaccount

or you can SAP BTP redis service. It can only be reached via an SSH tunnel (see: [Access a Redis-cache Instance from Redis-cli](https://help.sap.com/docs/redis-hyperscaler-option/redis-on-sap-btp-hyperscaler-option/access-redis-cache-instance-from-redis-cli)). The command to establish the tunnel is:

```bash
cf ssh -L 6380:<your-redis-hostname>:6380 mtxs-bookshop-srv
```

to make the connection work you have to add the redis hostname to the hosts file so that it can be resolved to `localhost` (where the tunnel is listening).

Now you can bind the redis service to the project using the following command:

```bash
cds bind eventqueue-redis-cache --to mtxs-bookshop-redis-cache
```

## Create Services & Service Keys

For an easy creation of the services build the project using `mbt build` and deploy it to the Cloud Foundry provider subaccount using `cf deploy mta_archives/mtxs-bookshop_1.0.0.mtar`. Then create the service keys using the following commands:

```bash
cf csk mtxs-bookshop-db mtxs-bookshop-db-key
cf csk mtxs-bookshop-destination mtxs-bookshop-destination-key
cf csk mtxs-bookshop-uaa mtxs-bookshop-uaa-key
cf csk mtxs-bookshop-workzone mtxs-bookshop-workzone-key
cf csk mtxs-bookshop-repo-runtime mtxs-bookshop-repo-runtime-key
cf csk mtxs-bookshop-credstore-dev mtxs-bookshop-credstore-dev-key
```

## Bind the CAP App to the service

```bash
cds bind -2 mtxs-bookshop-db
cds bind -2 mtxs-bookshop-destination
cds bind -2 mtxs-bookshop-connectivity
cds bind -2 mtxs-bookshop-uaa
cds bind -2 mtxs-bookshop-workzone
cds bind -2 mtxs-bookshop-repo-runtime
cds bind -2 mtxs-bookshop-credstore-dev
cds bind -2 mtxs-bookshop-theming
```

## Run local with dynamic binding

To try with the central service create a `default-env.json` and point it to the port where [bookshop-demo](https://github.com/gregorwolf/bookshop-demo) is running.

```JSON
{
  "destinations": [
    {
      "name": "CatalogService",
      "url": "http://localhost:4003"
    }
  ]
}
```

To run with mocked authentication also in hybrid mode you have to remove the line

```
"kind": "xsuaa",
```

from the `.cdsrc-private.json` file.

When running with `cds watch --profile hybrid` the deployment of tenant containers fail. So please use:

```bash
npm run start:hybrid
```

## Test deployed app

Create a consumer subaccount, go to the Service Marketplace and create a subscription for the app `mtxs-bookshop`. When you run `cf logs mtxs-bookshop-srv` in parallel you should see a successful subscription when the UPS `<subscribedSubdomain>_CS1HDIAdb` was existing in the provider subaccount.
