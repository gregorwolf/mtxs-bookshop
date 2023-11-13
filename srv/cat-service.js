module.exports = cds.service.impl(async function () {
  const catService = await cds.connect.to("srv.external.CatalogService");

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
