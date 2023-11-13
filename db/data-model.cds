namespace my.bookshop;

using {cuid} from '@sap/cds/common';
using {srv.external.CatalogService as external} from '../srv/external/CatalogService';

entity Books : cuid {
  title  : String(200);
  // description : String(5000);
  stock  : Integer;
  author : Association to Authors;
}

entity Authors as projection on external.Authors {
  key ID,
      name,
      books : Association to many Books on books.author = $self,
};

@cds.persistence.exists
entity CS1TAB {
  key SalesOrderId : String(10) not null;
      ProductId    : String(10) not null;
      Quantity     : Integer;
      DeliveryDate : Date;
}
