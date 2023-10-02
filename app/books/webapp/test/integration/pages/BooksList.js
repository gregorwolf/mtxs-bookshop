sap.ui.define(["sap/fe/test/ListReport"], function (ListReport) {
  "use strict";

  var CustomPageDefinitions = {
    actions: {},
    assertions: {},
  };

  return new ListReport(
    {
      appId: "csw.demo.mtxs.books",
      componentId: "BooksList",
      entitySet: "Books",
    },
    CustomPageDefinitions
  );
});
