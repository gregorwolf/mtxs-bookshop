const cds = require("@sap/cds");
const LOG = cds.log("cat-service");
const eventQueue = require("@cap-js-community/event-queue");

const { sendMail, MailConfig } = require("@sap-cloud-sdk/mail-client");
const {
  retrieveJwt,
  getDestination,
  getDestinationFromDestinationService,
  alwaysSubscriber,
} = require("@sap-cloud-sdk/connectivity");
const { executeHttpRequest } = require("@sap-cloud-sdk/http-client");

module.exports = cds.service.impl(async function () {
  const catService = await cds.connect.to("srv.external.CatalogService");

  this.on(["getUsers"], async (req) => {
    let userList = [];
    const destinationName =
      process.env.XSUAA_APIACCESS_DEST || "XSUAA_APIAccess";
    const apiEndPoint =
      "/sap/rest/authorization/v2/rolecollections/?showGroups=false&showRoles=false&showUsers=true";
    const jwt = retrieveJwt(cds.context);
    const targetDestinationOptions = {
      destinationName,
      jwt,
      selectionStrategy: alwaysSubscriber,
    };
    const destination = await getDestinationFromDestinationService(
      targetDestinationOptions
    );
    const apiURL = `${destination?.url}${apiEndPoint}`;
    try {
      const response = await executeHttpRequest(destination, {
        method: "GET",
        url: apiURL,
        headers: { "Content-Type": "application/json" },
      });
      userList = response.data.flatMap((item) => item.userReferences || []);
    } catch (error) {
      console.error(
        "Error fetching user info!",
        error.response?.data || error.message
      );
    }
    return userList;
  });

  this.on(["sendmail"], async (req) => {
    if (!req.data.sender) {
      return req.error("You must specify a sender");
    }
    if (!req.data.to) {
      return req.error("You must specify a recipient");
    }
    if (!req.data.subject) {
      return req.error("You must specify a subject");
    }
    if (!req.data.body) {
      return req.error("You must specify a body");
    }
    const destination = req.data.destination || "inbucket";
    try {
      const mailConfig = {
        from: req.data.sender,
        to: req.data.to,
        subject: req.data.subject,
        text: req.data.body,
      };
      const jwt = retrieveJwt(req);
      const resolvedDestination = await getDestination({
        destinationName: destination,
        jwt,
        selectionStrategy: alwaysSubscriber,
      });

      const mailClientOptions = {};
      // mail. properties allow only lowercase
      if (
        resolvedDestination.originalProperties[
          "mail.clientoptions.ignoretls"
        ] === "true"
      ) {
        mailClientOptions.ignoreTLS = true;
      }
      // use sendmail as you should use it in nodemailer
      const result = await sendMail(
        resolvedDestination,
        [mailConfig],
        mailClientOptions
      );
      return JSON.stringify(result);
    } catch (error) {
      LOG.info(error);
      return req.error(error);
    }
  });

  this.on(["sendmailEvent"], async (req) => {
    await eventQueue.publishEvent(cds.tx(req), {
      type: "Mail",
      subType: "Single",
      payload: JSON.stringify(req.data),
    });
  });

  this.on("READ", "Authors", (req) => {
    return catService.run(req.query);
  });

  // Books?$expand=author
  this.on("READ", "Books", async (req, next) => {
    if (!req.query.SELECT.columns) return next();
    const expandIndex = req.query.SELECT.columns.findIndex(
      ({ expand, ref }) => expand && ref[0] === "author"
    );
    if (expandIndex < 0) return next();

    // Remove expand from query
    req.query.SELECT.columns.splice(expandIndex, 1);

    // Make sure author_ID will be returned
    if (
      !req.query.SELECT.columns.indexOf("*") >= 0 &&
      !req.query.SELECT.columns.find(
        (column) => column.ref && column.ref.find((ref) => ref == "author_ID")
      )
    ) {
      req.query.SELECT.columns.push({ ref: ["author_ID"] });
    }

    const Books = await next();

    const asArray = (x) => (Array.isArray(x) ? x : [x]);

    // Request all associated Authors
    const authorIds = asArray(Books).map((risk) => risk.author_ID);
    const Authors = await catService.run(
      SELECT.from("Authors").where({ ID: authorIds })
    );

    // Convert in a map for easier lookup
    const AuthorsMap = {};
    for (const author of Authors) AuthorsMap[author.ID] = author;

    // Add Authors to result
    for (const note of asArray(Books)) {
      note.author = AuthorsMap[note.author_ID];
    }

    return Books;
  });
});
