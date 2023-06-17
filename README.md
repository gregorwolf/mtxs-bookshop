# MTXS Bookshop

Welcome this CAP project.

It contains these folders and files, following our recommended project layout:

| File or Folder | Purpose                              |
| -------------- | ------------------------------------ |
| `app/`         | content for UI frontends goes here   |
| `db/`          | your domain models and data go here  |
| `srv/`         | your service models and code go here |
| `package.json` | project metadata and configuration   |
| `readme.md`    | this getting started guide           |

## Create Services & Service Keys

```bash
cf cs service-manager container mtxs-bookshop-db
cf cs destination lite mtxs-bookshop-destination
cf cs xsuaa broker mtxs-bookshop-uaa -c xs-security.json
cf csk mtxs-bookshop-db mtxs-bookshop-db-key
cf csk mtxs-bookshop-destination mtxs-bookshop-destination-key
cf csk mtxs-bookshop-uaa mtxs-bookshop-uaa-key
```

## Bind the CAP App to the service

```bash
cds bind -2 mtxs-bookshop-db
cds bind -2 mtxs-bookshop-destination
cds bind -2 mtxs-bookshop-uaa
```

## Run with dynamic binding

To run with mocked authentication also in hybrid mode you have to remove the line

```
"kind": "xsuaa",
```

from the `.cdsrc-private.json` file.

When running with `cds watch --profile hybrid` the deployment of tenant containers fail. So please use:

```bash
npm run start:hybrid
```
