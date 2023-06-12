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

## Create Service Manager & Service Key

```bash
cf cs service-manager container mtxs-bookshop-db
cf csk mtxs-bookshop-db mtxs-bookshop-db-key
```

## Bind the CAP App to the service

```bash
cds bind -2 mtxs-bookshop-db
```

## Run with dynamic binding

When running with `cds watch --profile hybrid` the deployment of tenant containers fail. So please use:

```bash
cds bind --exec -- cds run --profile hybrid
```
