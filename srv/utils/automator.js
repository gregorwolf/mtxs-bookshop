const cds = require("@sap/cds");
const LOG = cds.log("mtxs-custom-automator");
const cfenv = require("cfenv");
const appEnv = cfenv.getAppEnv();
const xsenv = require("@sap/xsenv");
xsenv.loadEnv();

const ServiceManager = require("./service-manager");
const CisCentral = require("./cis-central");
const credStore = require("./credStore");

class TenantAutomator {
  constructor() {
    this.credStore = credStore;
    this.credentials = new Map();
  }

  async deployTenantArtifacts(subscribingSubdomain, subscribingSubaccountId) {
    try {
      await this.initialize(subscribingSubaccountId);
      await this.registerBTPServiceBroker(subscribingSubdomain);
      await this.cleanUpCreatedServices(subscribingSubaccountId);
      LOG.info("Automation: Deployment has been completed successfully!");
    } catch (error) {
      throw error;
    }
  }

  async undeployTenantArtifacts(
    unsubscribingSubaccountId,
    unsubscribingSubdomain
  ) {
    try {
      await this.initialize(unsubscribingSubaccountId);
      await this.unregisterBTPServiceBroker(unsubscribingSubaccountId);
      await this.cleanUpCreatedServices(unsubscribingSubaccountId);
      LOG.info("Automation: Undeployment has been completed successfully!");
    } catch (error) {
      LOG.error("Tenant artifacts cannot be undeployed!");
      throw error;
    }
  }

  async initialize(subscribingSubdomainId) {
    try {
      await this.readCredentials();
      this.serviceManager = await this.createServiceManager(
        subscribingSubdomainId
      );
      LOG.info("Automator successfully initialized!");
    } catch (error) {
      LOG.error("Automation can not be initialized!");
      throw error;
    }
  }

  async createServiceManager(subscribingSubdomainId) {
    try {
      let btpAdmin = this.credentials.get("btp-admin-user");
      this.cisCentral = new CisCentral(btpAdmin.username, btpAdmin.value);
      let serviceManagerCredentials =
        await this.cisCentral.createServiceManager(subscribingSubdomainId);
      LOG.info("Service manager has been created successfully!");
      return new ServiceManager(serviceManagerCredentials);
    } catch (error) {
      LOG.error("Service Manager can not be created!");
      throw error;
    }
  }

  async readCredentials() {
    try {
      let creds = await Promise.all([
        this.credStore.readCredential(
          "mtxs-bookshop",
          "password",
          "btp-admin-user"
        ),
        this.credStore.readCredential(
          "mtxs-bookshop",
          "password",
          "susaas-broker-credentials"
        ),
      ]);
      creds.forEach((cred) => {
        this.credentials.set(cred.name, cred);
      });
      LOG.info("Credentials retrieved from credential store successfully");
    } catch (error) {
      LOG.error(
        "Unable to retrieve credentials from cred store, please make sure that they are created! Automation skipped!"
      );
      throw error;
    }
  }

  async cleanUpCreatedServices(tenantSubaccountId) {
    try {
      await this.cisCentral.deleteServiceManager(tenantSubaccountId);
      LOG.info("Service Manager is deleted");
    } catch (error) {
      LOG.error("Clean up can not be completed!");
      throw error;
    }
  }

  async registerBTPServiceBroker() {
    try {
      let sbCreds = this.credentials.get(`susaas-broker-credentials`);
      let sbUrl = await this.getServiceBrokerUrl();
      await this.serviceManager.createServiceBroker(
        `${process.env.brokerName}-${appEnv.app.space_name}`,
        sbUrl,
        "Sustainable SaaS API Broker",
        sbCreds.username,
        sbCreds.value
      );
      LOG.info("Susaas Inbound API Broker registered successfully!");
    } catch (error) {
      LOG.info("Service broker cannot be registered!");
    }
  }

  async unregisterBTPServiceBroker(subaccountId) {
    try {
      let sb = await this.serviceManager.getServiceBroker(
        `${process.env.brokerName}-${appEnv.app.space_name}-${subaccountId}`
      );
      await this.serviceManager.deleteServiceBroker(sb.id);
      LOG.info(`Service Broker ${process.env.brokerName} deleted`);
    } catch (error) {
      LOG.info(`Service Broker ${process.env.brokerName} can not be deleted`);
    }
  }

  async getServiceBrokerUrl() {
    try {
      LOG.info("Broker endpoint to be registered:", process.env.brokerUrl);
      return process.env.brokerUrl;
    } catch (error) {
      LOG.info(error.message);
      throw error;
    }
  }
}

module.exports = TenantAutomator;
