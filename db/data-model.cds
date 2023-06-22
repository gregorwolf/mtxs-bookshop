namespace my.bookshop;

entity Books {
  key ID    : Integer;
      title : String(200);
      // description : String(5000);
      stock : Integer;
}

@cds.persistence.exists
entity CS1TAB {
  key SalesOrderId : String(10) not null;
      ProductId    : String(10) not null;
      Quantity     : Integer;
      DeliveryDate : Date;
}
