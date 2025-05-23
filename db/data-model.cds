namespace my.bookshop;

using {
  cuid,
  managed
} from '@sap/cds/common';
//using {srv.external.CatalogService as external} from '../srv/external/CatalogService';
using {CatalogService_v2 as external} from '../srv/external/CatalogService-v2';


entity Books : cuid, managed {

  title  : String(200);
  // description : String --> NVARCHAR(5000);
  // description : LargeString --> NCLOB;
  stock  : Integer;
  author : Association to Authors;
}

entity Authors as
  projection on external.Authors {
    key ID,
        name,
        books : Association to many Books
                  on books.author = $self,
    };

@cds.persistence.exists
entity CS1TAB {
  key SalesOrderId : String(10) not null;
      ProductId    : String(10) not null;
      Quantity     : Integer;
      DeliveryDate : Date;
}
