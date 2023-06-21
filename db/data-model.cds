namespace my.bookshop;

entity Books {
  key ID    : Integer;
      title : String;
      stock : Integer;
}

@cds.persistence.exists
entity CS1TAB {
  key SalesOrderId : String(10) not null;
      ProductId    : String(10) not null;
      Quantity     : Integer;
      DeliveryDate : Date;
}
