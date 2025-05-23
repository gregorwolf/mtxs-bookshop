/* checksum : a0195edd5c0d7b3f630e4344a92af5cc */
@cds.external : true
@m.IsDefaultEntityContainer : 'true'
service CatalogService_v2 {};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Books {
  key ID : Integer not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  title : String(111);
  descr : String(1111);
  genre_ID : Integer;
  stock : Integer;
  stockTarget : Integer;
  @sap.unit : 'currency_code'
  @sap.variable.scale : 'true'
  price : Decimal;
  @sap.semantics : 'currency-code'
  currency_code : String(3);
  virtualFromDB : LargeString;
  semanticURLtoPublisher : LargeString;
  @sap.variable.scale : 'true'
  weight : Decimal;
  height : Double;
  width : Decimal(9, 2);
  visible : Boolean;
  @odata.Type : 'Edm.DateTimeOffset'
  releaseDate : DateTime;
  readingTime : Time;
  author_ID : Integer;
  publisher_ID : Integer;
  VirtualFromSrv : LargeString;
  genre : Association to CatalogService_v2.Genres {  };
  @sap.semantics : 'currency-code'
  currency : Association to CatalogService_v2.Currencies {  };
  author : Association to CatalogService_v2.Authors {  };
  publisher : Association to CatalogService_v2.Publishers {  };
  plants : Association to many CatalogService_v2.BookPlants {  };
  to_BooksAuthorsAssignment : Association to CatalogService_v2.BooksAuthorsAssignment {  };
  texts : Composition of many CatalogService_v2.Books_texts {  };
  localized : Association to CatalogService_v2.Books_texts {  };
} actions {
  action Books_updateBook();
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.BooksAuthorsAssignment {
  key Role : String(50) not null;
  key ASSOC_Book_ID : Integer not null;
  key ASSOC_Author_ID : Integer not null;
  ASSOC_Book : Association to CatalogService_v2.Books {  };
  ASSOC_Author : Association to CatalogService_v2.Authors {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Authors {
  key ID : Integer not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  name : String(111);
  @sap.display.format : 'Date'
  dateOfBirth : Date;
  @sap.display.format : 'Date'
  dateOfDeath : Date;
  placeOfBirth : LargeString;
  placeOfDeath : LargeString;
  alive : Boolean;
  country_code : String(3);
  country : Association to CatalogService_v2.Countries {  };
  BooksAuthorsAssignment_ASSOC_Authors : Association to many CatalogService_v2.BooksAuthorsAssignment {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Publishers {
  key ID : Integer not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  name : String(111);
  book : Association to many CatalogService_v2.Books {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Orders {
  key ID : UUID not null;
  OrderNo : LargeString;
  salesOrganization : String(4) not null;
  CustomerOrderNo : String(80);
  ShippingAddress_ID : UUID;
  @sap.variable.scale : 'true'
  total : Decimal;
  totalTax : Decimal(15, 2);
  totalWithTax : Double;
  orderstatus_code : String(1);
  deliverystatus_code : String(1);
  currency_code : String(3);
  createdBy : String(255);
  Items : Composition of many CatalogService_v2.OrderItems {  };
  ShippingAddress : Composition of CatalogService_v2.OrderShippingAddress {  };
  orderstatus : Association to CatalogService_v2.Orderstatuses {  };
  deliverystatus : Association to CatalogService_v2.Deliverystatuses {  };
  currency : Association to CatalogService_v2.Currencies {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.UserScopes {
  key username : LargeString not null;
  is_admin : Boolean;
  is_roleadmin : Boolean;
  is_booksadmin : Boolean;
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.SEPMRA_I_Product_E {
  key Product : String(10) not null;
  ProductType : String(2);
  ProductCategory : String(40);
  CreatedByUser : String(10);
  LastChangedByUser : String(10);
  Price : Decimal(16, 3);
  Currency : String(5);
  Height : Decimal(13, 3);
  Width : Decimal(13, 3);
  Depth : Decimal(13, 3);
  DimensionUnit : String(3);
  ProductPictureURL : String(255);
  ProductValueAddedTax : Integer;
  Supplier : String(10);
  ProductBaseUnit : String(3);
  Weight : Decimal(13, 3);
  WeightUnit : String(3);
  OriginalLanguage : String(2);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Userdetails {
  key username : LargeString not null;
  authorizations_username : LargeString;
  authorizations : Association to CatalogService_v2.Authorizations {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Authorizations {
  key username : LargeString not null;
  is_admin : Boolean;
  is_roleadmin : Boolean;
  is_booksadmin : Boolean;
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Genres {
  key ID : Integer not null;
  name : String(255);
  descr : String(1000);
  parent_ID : Integer;
  nodeType : String(1);
  nodeType_FC : Integer;
  genreSemanticObject : LargeString;
  parent : Association to CatalogService_v2.Genres {  };
  children : Composition of many CatalogService_v2.Genres {  };
  texts : Composition of many CatalogService_v2.Genres_texts {  };
  localized : Association to CatalogService_v2.Genres_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Currencies {
  @sap.semantics : 'currency-code'
  key code : String(3) not null;
  name : String(255);
  descr : String(1000);
  symbol : String(5);
  minorUnit : Integer;
  decimalPlaces : Integer;
  texts : Composition of many CatalogService_v2.Currencies_texts {  };
  localized : Association to CatalogService_v2.Currencies_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.BookPlants {
  key book_ID : Integer not null;
  key plant_ID : String(4) not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  createdBy : String(255);
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  modifiedBy : String(255);
  purchasingGroup : String(3);
  stock : Integer;
  book : Association to CatalogService_v2.Books {  };
  plant : Association to CatalogService_v2.Plant {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Countries {
  key code : String(3) not null;
  name : String(255);
  descr : String(1000);
  texts : Composition of many CatalogService_v2.Countries_texts {  };
  localized : Association to CatalogService_v2.Countries_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.OrderItems {
  key ID : UUID not null;
  parent_ID : UUID not null;
  itemNo : Integer not null;
  book_ID : Integer;
  product : String(10);
  amount : Integer;
  netAmount : Decimal(9, 2);
  parent : Association to CatalogService_v2.Orders {  };
  book : Association to CatalogService_v2.Books {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.OrderShippingAddress {
  key ID : UUID not null;
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  createdBy : String(255);
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  modifiedBy : String(255);
  street : String(60);
  city : String(60);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Orderstatuses {
  key code : String(1) not null;
  name : String(255);
  descr : String(1000);
  texts : Composition of many CatalogService_v2.Orderstatuses_texts {  };
  localized : Association to CatalogService_v2.Orderstatuses_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Deliverystatuses {
  key code : String(1) not null;
  name : String(255);
  descr : String(1000);
  texts : Composition of many CatalogService_v2.Deliverystatuses_texts {  };
  localized : Association to CatalogService_v2.Deliverystatuses_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Plant {
  key ID : String(4) not null;
  name : String(255);
  descr : String(1000);
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  createdAt : Timestamp;
  createdBy : String(255);
  @odata.Type : 'Edm.DateTimeOffset'
  @odata.Precision : 7
  modifiedAt : Timestamp;
  modifiedBy : String(255);
  texts : Composition of many CatalogService_v2.Plant_texts {  };
  localized : Association to CatalogService_v2.Plant_texts {  };
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Books_texts {
  key locale : String(14) not null;
  key ID : Integer not null;
  title : String(111);
  descr : String(1111);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Genres_texts {
  key locale : String(14) not null;
  key ID : Integer not null;
  name : String(255);
  descr : String(1000);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Currencies_texts {
  key locale : String(14) not null;
  @sap.semantics : 'currency-code'
  key code : String(3) not null;
  name : String(255);
  descr : String(1000);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Countries_texts {
  key locale : String(14) not null;
  key code : String(3) not null;
  name : String(255);
  descr : String(1000);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Orderstatuses_texts {
  key locale : String(14) not null;
  key code : String(1) not null;
  name : String(255);
  descr : String(1000);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Deliverystatuses_texts {
  key locale : String(14) not null;
  key code : String(1) not null;
  name : String(255);
  descr : String(1000);
};

@cds.external : true
@cds.persistence.skip : true
entity CatalogService_v2.Plant_texts {
  key ID_texts : UUID not null;
  locale : String(14);
  name : String(255);
  descr : String(1000);
  ID : String(4);
};

@cds.external : true
type CatalogService_v2.DynamicAppLauncher {
  icon : LargeString;
  info : LargeString;
  infoState : LargeString;
  number : Decimal(9, 2);
  numberDigits : Integer;
  numberFactor : LargeString;
  numberState : LargeString;
  numberUnit : LargeString;
  stateArrow : LargeString;
  subtitle : LargeString;
  title : LargeString;
};

@cds.external : true
function CatalogService_v2.getBooks() returns many CatalogService_v2.Books;

@cds.external : true
function CatalogService_v2.getNumberOfBooksForDynamicTile() returns CatalogService_v2.DynamicAppLauncher;

@cds.external : true
function CatalogService_v2.hello(
  to : LargeString
) returns LargeString;

@cds.external : true
action CatalogService_v2.submitOrder(
  book : Integer,
  amount : Integer
);

@cds.external : true
action CatalogService_v2.multipleOrders(
  numberOfOrders : Integer
);

