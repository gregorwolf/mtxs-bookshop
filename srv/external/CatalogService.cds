namespace srv.external;


/* checksum : 33a874b99a25b7f3abac5aa8265b0e3c */
@cds.external: true
function CatalogService.getBooks()                       returns many CatalogService.Books not null;

@cds.external: true
function CatalogService.getNumberOfBooksForDynamicTile() returns CatalogService.DynamicAppLauncher;

@cds.external: true
function CatalogService.hello(to : LargeString)          returns LargeString;

@cds.external: true
action   CatalogService.submitOrder(
                                    @Common.Text:title
                                    @Common.Text.@UI.TextArrangement: #TextFirst
                                    @Common.Label:'ID'
                                    book : Integer,
                                    amount : Integer);

@cds.external: true
action   CatalogService.multipleOrders(numberOfOrders : Integer);

@cds.external                               : true
@cds.persistence.skip                       : true
@UI.HeaderFacets                            : [{
  $Type: 'UI.ReferenceFacet',
  Label: 'Description'
}]
@UI.Facets                                  : [{
  $Type: 'UI.ReferenceFacet',
  Label: 'Details'
}]
@UI.FieldGroup #Descr                       : {
  $Type: 'UI.FieldGroupType',
  Data : [{
    $Type: 'UI.DataField',
    Value: descr
  }]
}
@UI.FieldGroup #Price                       : {
  $Type: 'UI.FieldGroupType',
  Data : [
    {
      $Type: 'UI.DataField',
      Value: price
    },
    {
      $Type: 'UI.DataField',
      Value: ![currency/symbol] ,
      Label: 'Currency'
    }
  ]
}
@UI.PresentationVariant                     : {
  $Type    : 'UI.PresentationVariantType',
  MaxItems : 10,
  SortOrder: [{
    $Type     : 'Common.SortOrderType',
    Property  : stock,
    Descending: true
  }]
}
@UI.Identification                          : [{
  $Type: 'UI.DataField',
  Value: title
}]
@UI.SelectionFields                         : [
  'ID',
  'title',
  'author/name',
  'stock'
]
@UI.LineItem                                : [
  {
    $Type: 'UI.DataField',
    Value: ID
  },
  {
    $Type: 'UI.DataField',
    Value: stock
  },
  {
    $Type: 'UI.DataField',
    Value: title
  },
  {
    $Type: 'UI.DataField',
    Value: author_ID
  },
  {
    $Type: 'UI.DataField',
    Value: ![author/name]
  },
  {
    $Type         : 'UI.DataFieldWithIntentBasedNavigation',
    Value         : ![author/ID] ,
    Label         : 'V2 Action for Navigation to Author',
    SemanticObject: 'Authors',
    Action        : 'displayUI5latest',
    Mapping       : [{
      $Type                 : 'Common.SemanticObjectMappingType',
      LocalProperty         : author_ID,
      SemanticObjectProperty: 'ID'
    }]
  },
  {
    $Type         : 'UI.DataField',
    Value         : price,
    @UI.Importance: #High
  },
  {
    $Type         : 'UI.DataField',
    Value         : ![currency/symbol] ,
    @UI.Importance: #High
  },
  {
    $Type  : 'UI.DataFieldWithUrl',
    Label  : 'To Publisher Url',
    IconUrl: 'sap-icon://chain-link',
    Value  : publisher_ID,
    Url    : semanticURLtoPublisher
  }
]
@UI.HeaderInfo                              : {
  $Type         : 'UI.HeaderInfoType',
  TypeName      : 'Book',
  TypeNamePlural: 'Books',
  Title         : {
    $Type: 'UI.DataField',
    Value: title
  },
  ImageUrl      : 'https://raw.githubusercontent.com/gregorwolf/bookshop-demo/master/tests/Test.png',
  Description   : {
    $Type: 'UI.DataField',
    Value: ![author/name]
  }
}
@Capabilities.SearchRestrictions.Searchable : true
@Capabilities.InsertRestrictions.Insertable : true
@Capabilities.InsertRestrictions.Permissions: [{Scopes: [{Scope: 'admin'}]}]
@Capabilities.UpdateRestrictions.Updatable  : true
@Capabilities.DeleteRestrictions.Deletable  : true
entity CatalogService.Books {
      @odata.Precision                : 7
      @odata.Type                     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter                : true
      @Core.Immutable                 : true
      @Core.Computed                  : true
      @Common.Label                   : 'Created On'
      createdAt                 : Timestamp;

      @odata.Precision                : 7
      @odata.Type                     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter                : true
      @Core.Computed                  : true
      @Common.Label                   : 'Changed On'
      modifiedAt                : Timestamp;

      @Common.Text                    : title
      @Common.Text.@UI.TextArrangement: #TextFirst
      @Common.Label                   : 'ID'
  key ID                        : Integer not null;

      @Common.Label                   : 'Title'
      title                     : String(111);

      @UI.MultiLineText               : true
      descr                     : String(1111);

      @cds.ambiguous                  : 'missing on condition?'
      genre                     : Association to one CatalogService.Genres
                                    on genre.ID = genre_ID;

      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Genres',
        CollectionPath: 'Genres',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: genre_ID,
            ValueListProperty: 'ID'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      genre_ID                  : Integer;

      @Common.Label                   : 'Stock'
      stock                     : Integer;

      @Measures.ISOCurrency           : currency_code
      @Common.Label                   : 'Price'
      price                     : Decimal;

      /**
       * Currency code as specified by ISO 4217
       */
      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Currency'
      currency                  : Association to one CatalogService.Currencies
                                    on currency.code = currency_code;

      /**
       * Currency code as specified by ISO 4217
       */
      @Common.IsCurrency              : true
      @Common.Label                   : 'Currency'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Currency',
        CollectionPath: 'Currencies',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: currency_code,
            ValueListProperty: 'code'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      currency_code             : String(3);

      @Core.Computed                  : true
      virtualFromDB             : LargeString default 'Value from DB';

      @Core.Computed                  : true
      semanticURLtoPublisher    : LargeString;

      @Common.Label                   : 'Weight (DecimalFloat)'
      weight                    : Decimal;

      @Common.Label                   : 'Height (Double)'
      height                    : Double;

      @Common.Label                   : 'Width (Decimal(9,2))'
      width                     : Decimal(9, 2);

      @Common.Label                   : 'Visible (Boolean)'
      visible                   : Boolean;

      @odata.Precision                : 0
      @odata.Type                     : 'Edm.DateTimeOffset'
      @Common.Label                   : 'Release Date (DateTime)'
      releaseDate               : DateTime;

      @Common.Label                   : 'Reading Time (Time)'
      readingTime               : Time;

      @cds.ambiguous                  : 'missing on condition?'
      @Common.SemanticObject          : 'V4Authors'
      @Common.Label                   : 'Author ID'
      author                    : Association to one CatalogService.Authors
                                    on author.ID = author_ID;

      @Common.SemanticObject          : 'V4Authors'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Author ID',
        CollectionPath: 'Authors',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: author_ID,
            ValueListProperty: 'ID'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      @Common.Label                   : 'Author ID'
      author_ID                 : Integer;

      @cds.ambiguous                  : 'missing on condition?'
      publisher                 : Association to one CatalogService.Publishers
                                    on publisher.ID = publisher_ID;
      publisher_ID              : Integer;

      @cds.ambiguous                  : 'missing on condition?'
      plants                    : Association to many CatalogService.BookPlants {};

      @cds.ambiguous                  : 'missing on condition?'
      to_BooksAuthorsAssignment : Association to one CatalogService.BooksAuthorsAssignment
                                    on to_BooksAuthorsAssignment.ASSOC_Book_ID = ID;

      @cds.ambiguous                  : 'missing on condition?'
      texts                     : Composition of many CatalogService.Books_texts;

      @cds.ambiguous                  : 'missing on condition?'
      localized                 : Association to one CatalogService.Books_texts
                                    on localized.ID = ID;

      @Core.Computed                  : true
      VirtualFromSrv            : LargeString;
} actions {
  action updateBook(![in] : $self);
};

@cds.external                              : true
@cds.persistence.skip                      : true
@Capabilities.DeleteRestrictions.Deletable : false
@Capabilities.InsertRestrictions.Insertable: false
@Capabilities.UpdateRestrictions.Updatable : false
entity CatalogService.BooksAuthorsAssignment {
  key Role            : String(50) not null;

      @cds.ambiguous: 'missing on condition?'
      ASSOC_Book      : Association to one CatalogService.Books
                          on ASSOC_Book.ID = ASSOC_Book_ID;
  key ASSOC_Book_ID   : Integer not null;

      @cds.ambiguous: 'missing on condition?'
      ASSOC_Author    : Association to one CatalogService.Authors
                          on ASSOC_Author.ID = ASSOC_Author_ID;
  key ASSOC_Author_ID : Integer not null;
};

@cds.external                              : true
@cds.persistence.skip                      : true
@UI.Identification                         : [{
  $Type: 'UI.DataField',
  Value: name
}]
@UI.SelectionFields                        : [
  'ID',
  'name',
  'alive'
]
@UI.LineItem                               : [
  {
    $Type: 'UI.DataField',
    Value: ID
  },
  {
    $Type: 'UI.DataField',
    Value: name
  },
  {
    $Type: 'UI.DataField',
    Value: dateOfBirth
  },
  {
    $Type: 'UI.DataField',
    Value: placeOfBirth
  },
  {
    $Type: 'UI.DataField',
    Value: dateOfDeath
  },
  {
    $Type: 'UI.DataField',
    Value: placeOfDeath
  },
  {
    $Type: 'UI.DataField',
    Value: ![country/name]
  },
  {
    $Type         : 'UI.DataFieldWithIntentBasedNavigation',
    Label         : 'To Books Intent Based',
    Value         : ID,
    SemanticObject: 'Books',
    Action        : 'displayUI5latest'
  }
]
@UI.HeaderInfo                             : {
  $Type         : 'UI.HeaderInfoType',
  TypeName      : 'Author',
  TypeNamePlural: 'Authors',
  Title         : {
    $Type: 'UI.DataField',
    Value: ID
  },
  Description   : {
    $Type: 'UI.DataField',
    Value: name
  }
}
@UI.Facets                                 : [
  {
    $Type: 'UI.ReferenceFacet',
    Label: 'Details'
  },
  {
    $Type: 'UI.ReferenceFacet',
    Label: 'Books'
  }
]
@UI.FieldGroup #Details                    : {
  $Type: 'UI.FieldGroupType',
  Data : [
    {
      $Type: 'UI.DataField',
      Value: name
    },
    {
      $Type: 'UI.DataField',
      Value: dateOfBirth
    },
    {
      $Type: 'UI.DataField',
      Value: placeOfBirth
    },
    {
      $Type: 'UI.DataField',
      Value: dateOfDeath
    },
    {
      $Type: 'UI.DataField',
      Value: placeOfDeath
    }
  ]
}
@UI.QuickViewFacets                        : [{
  $Type: 'UI.ReferenceFacet',
  Label: 'Author'
}]
@UI.FieldGroup #AuthorQuickView            : {
  $Type: 'UI.FieldGroupType',
  Data : [
    {
      $Type: 'UI.DataField',
      Value: name
    },
    {
      $Type: 'UI.DataField',
      Value: dateOfBirth
    },
    {
      $Type: 'UI.DataField',
      Value: placeOfBirth
    }
  ]
}
@Capabilities.DeleteRestrictions.Deletable : false
@Capabilities.InsertRestrictions.Insertable: false
@Capabilities.UpdateRestrictions.Updatable : false
entity CatalogService.Authors {
      @odata.Precision                : 7
      @odata.Type                     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter                : true
      @Core.Immutable                 : true
      @Core.Computed                  : true
      @Common.Label                   : 'Created On'
      createdAt                            : Timestamp;

      @odata.Precision                : 7
      @odata.Type                     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter                : true
      @Core.Computed                  : true
      @Common.Label                   : 'Changed On'
      modifiedAt                           : Timestamp;

      @Common.Text                    : name
      @Common.Text.@UI.TextArrangement: #TextFirst
      @Common.Label                   : 'ID'
      @UI.HiddenFilter                : true
  key ID                                   : Integer not null;

      @Common.Label                   : 'Author''''s Name'
      name                                 : String(111);
      dateOfBirth                          : Date;
      dateOfDeath                          : Date;
      placeOfBirth                         : LargeString;
      placeOfDeath                         : LargeString;
      alive                                : Boolean;

      /**
       * Country/region code as specified by ISO 3166-1
       */
      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Country/Region'
      country                              : Association to one CatalogService.Countries
                                               on country.code = country_code;

      /**
       * Country/region code as specified by ISO 3166-1
       */
      @Common.Label                   : 'Country/Region'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Country/Region',
        CollectionPath: 'Countries',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: country_code,
            ValueListProperty: 'code'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      country_code                         : String(3);

      @cds.ambiguous                  : 'missing on condition?'
      BooksAuthorsAssignment_ASSOC_Authors : Association to many CatalogService.BooksAuthorsAssignment {};
};

@cds.external                              : true
@cds.persistence.skip                      : true
@UI.Identification                         : [{
  $Type: 'UI.DataField',
  Value: name
}]
@UI.SelectionFields                        : [
  'ID',
  'name'
]
@UI.LineItem                               : [
  {
    $Type: 'UI.DataField',
    Value: ID
  },
  {
    $Type: 'UI.DataField',
    Value: name
  },
  {
    $Type         : 'UI.DataFieldWithIntentBasedNavigation',
    Label         : 'To Books Intent Based',
    Value         : ID,
    SemanticObject: 'Books',
    Action        : 'display',
    Mapping       : [{
      $Type                 : 'Common.SemanticObjectMappingType',
      LocalProperty         : ID,
      SemanticObjectProperty: 'publisher_ID'
    }]
  }
]
@UI.HeaderInfo                             : {
  $Type         : 'UI.HeaderInfoType',
  TypeName      : 'Publisher',
  TypeNamePlural: 'Publishers',
  Title         : {
    $Type: 'UI.DataField',
    Value: ID
  },
  Description   : {
    $Type: 'UI.DataField',
    Value: name
  }
}
@UI.Facets                                 : [
  {
    $Type: 'UI.ReferenceFacet',
    Label: 'Details'
  },
  {
    $Type: 'UI.ReferenceFacet',
    Label: 'Books'
  }
]
@UI.FieldGroup #Details                    : {
  $Type: 'UI.FieldGroupType',
  Data : [{
    $Type: 'UI.DataField',
    Value: name
  }]
}
@Capabilities.DeleteRestrictions.Deletable : false
@Capabilities.InsertRestrictions.Insertable: false
@Capabilities.UpdateRestrictions.Updatable : false
entity CatalogService.Publishers {
      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Immutable : true
      @Core.Computed  : true
      @Common.Label   : 'Created On'
      createdAt  : Timestamp;

      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Computed  : true
      @Common.Label   : 'Changed On'
      modifiedAt : Timestamp;
  key ID         : Integer not null;

      /**
       * The Publisher of a Book
       */
      @Common.Label   : 'Publisher'
      name       : String(111);

      @cds.ambiguous  : 'missing on condition?'
      book       : Association to many CatalogService.Books {};
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Orders {
  key ID                  : UUID not null;

      @Core.Immutable                 : true
      @Common.Label                   : 'Order Number'
      OrderNo             : LargeString;

      /**
       * Sales Organization
       *
       * An organizational area for sales that combines the
       * sales-relevant master data for customers, products, and
       * price lists.
       */
      @Core.Immutable                 : true
      @Common.QuickInfo               : 'An organizational area for sales that combines the sales-relevant master data for customers, products, and price lists.'
      @Common.Label                   : 'Sales Organization'
      salesOrganization   : String(4) not null;

      @Common.Label                   : 'Customer Order Number'
      CustomerOrderNo     : String(80);

      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Items'
      Items               : Composition of many CatalogService.OrderItems;

      @cds.ambiguous                  : 'missing on condition?'
      ShippingAddress     : Composition of one CatalogService.OrderShippingAddress
                              on ShippingAddress.ID = ShippingAddress_ID;
      ShippingAddress_ID  : UUID;

      @Measures.ISOCurrency           : ![currency/code]
      @Core.Computed                  : true
      total               : Decimal;

      @Measures.ISOCurrency           : ![currency/code]
      @Core.Computed                  : true
      totalTax            : Decimal(15, 2);

      @Measures.ISOCurrency           : ![currency/code]
      @Core.Computed                  : true
      totalWithTax        : Double;

      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Orderstatus'
      @UI.Hidden                      : {$If: [
        {$Eq: [
          {$Path: 'orderstatus_code'},
          'N'
        ]},
        false,
        true
      ]}
      orderstatus         : Association to one CatalogService.Orderstatuses
                              on orderstatus.code = orderstatus_code;

      @Common.ValueListWithFixedValues: true
      @Common.Text                    : ![orderstatus/descr]
      @Common.Text.@UI.TextArrangement: #TextOnly
      @Common.Label                   : 'Orderstatus'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Orderstatus',
        CollectionPath: 'Orderstatuses',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: orderstatus_code,
            ValueListProperty: 'code'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      @UI.Hidden                      : {$If: [
        {$Eq: [
          {$Path: 'orderstatus_code'},
          'N'
        ]},
        false,
        true
      ]}
      @Core.Computed                  : true
      orderstatus_code    : String(1);

      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Deliverystatus'
      deliverystatus      : Association to one CatalogService.Deliverystatuses
                              on deliverystatus.code = deliverystatus_code;

      @Common.ValueListWithFixedValues: true
      @Common.Label                   : 'Deliverystatus'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Deliverystatus',
        CollectionPath: 'Deliverystatuses',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: deliverystatus_code,
            ValueListProperty: 'code'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      @Core.Computed                  : true
      deliverystatus_code : String(1);

      /**
       * Currency code as specified by ISO 4217
       */
      @cds.ambiguous                  : 'missing on condition?'
      @Common.Label                   : 'Currency'
      currency            : Association to one CatalogService.Currencies
                              on currency.code = currency_code;

      /**
       * Currency code as specified by ISO 4217
       */
      @Core.Immutable                 : true
      @Common.Label                   : 'Currency'
      @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        Label         : 'Currency',
        CollectionPath: 'Currencies',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: currency_code,
            ValueListProperty: 'code'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      currency_code       : String(3);

      /**
       * User's unique ID
       */
      @UI.HiddenFilter                : true
      @Core.Immutable                 : true
      @Core.Computed                  : true
      @Common.Label                   : 'Created By'
      createdBy           : String(255);
};

@cds.external                             : true
@cds.persistence.skip                     : true
@odata.singleton                          : true
@Capabilities.DeleteRestrictions.Deletable: false
@Capabilities.UpdateRestrictions.Updatable: false
entity CatalogService.UserScopes {
  key username      : LargeString not null;
      is_admin      : Boolean;
      is_roleadmin  : Boolean;
      is_booksadmin : Boolean;
};

@cds.external                              : true
@cds.persistence.skip                      : true
@Capabilities.DeleteRestrictions.Deletable : false
@Capabilities.InsertRestrictions.Insertable: false
@Capabilities.UpdateRestrictions.Updatable : false
entity CatalogService.SEPMRA_I_Product_E {
  key Product              : String(10) not null;
      ProductType          : String(2);
      ProductCategory      : String(40);
      CreatedByUser        : String(10);
      LastChangedByUser    : String(10);
      Price                : Decimal(16, 3);
      Currency             : String(5);
      Height               : Decimal(13, 3);
      Width                : Decimal(13, 3);
      Depth                : Decimal(13, 3);
      DimensionUnit        : String(3);
      ProductPictureURL    : String(255);
      ProductValueAddedTax : Integer;
      Supplier             : String(10);
      ProductBaseUnit      : String(3);
      Weight               : Decimal(13, 3);
      WeightUnit           : String(3);
      OriginalLanguage     : String(2);
};

@cds.external                             : true
@cds.persistence.skip                     : true
@odata.singleton                          : true
@Capabilities.DeleteRestrictions.Deletable: false
@Capabilities.UpdateRestrictions.Updatable: false
entity CatalogService.Userdetails {
  key username                : LargeString not null;

      @cds.ambiguous: 'missing on condition?'
      authorizations          : Association to one CatalogService.Authorizations
                                  on authorizations.username = authorizations_username;
      authorizations_username : LargeString;
};

@cds.external                             : true
@cds.persistence.skip                     : true
@odata.singleton                          : true
@Capabilities.DeleteRestrictions.Deletable: false
@Capabilities.UpdateRestrictions.Updatable: false
entity CatalogService.Authorizations {
  key username      : LargeString not null;
      is_admin      : Boolean;
      is_roleadmin  : Boolean;
      is_booksadmin : Boolean;
};

@cds.external          : true
@cds.persistence.skip  : true
@UI.SelectionFields    : [
  'name',
  'parent_ID'
]
@UI.LineItem           : [
  {
    $Type: 'UI.DataField',
    Value: ID
  },
  {
    $Type: 'UI.DataField',
    Value: parent_ID
  },
  {
    $Type: 'UI.DataField',
    Value: name
  },
  {
    $Type: 'UI.DataField',
    Value: genreSemanticObject
  },
  {
    $Type: 'UI.DataField',
    Value: nodeType
  },
  {
    $Type: 'UI.DataField',
    Value: nodeType_FC
  }
]
@UI.Facets             : [{
  $Type: 'UI.ReferenceFacet',
  Label: 'Details'
}]
@UI.FieldGroup #Details: {
  $Type: 'UI.FieldGroupType',
  Data : [
    {
      $Type: 'UI.DataField',
      Value: ID
    },
    {
      $Type: 'UI.DataField',
      Value: name
    },
    {
      $Type: 'UI.DataField',
      Value: genreSemanticObject
    },
    {
      $Type: 'UI.DataField',
      Value: nodeType
    },
    {
      $Type: 'UI.DataField',
      Value: nodeType_FC
    }
  ]
}
@UI.Identification     : [{
  $Type: 'UI.DataField',
  Value: name
}]
@Common.SemanticKey    : ['ID']
@Common.SemanticObject : 'genres'
entity CatalogService.Genres {
      @Common.Label            : 'Name'
      name                : String(255);

      @Common.Label            : 'Description'
      descr               : String(1000);

      @Common.SemanticObject   : genreSemanticObject
      @Common.Label            : 'genreID'
  key ID                  : Integer not null;

      @cds.ambiguous           : 'missing on condition?'
      @Common.Label            : 'parent'
      parent              : Association to one CatalogService.Genres
                              on parent.ID = parent_ID;

      @Common.Label            : 'parent'
      @Common.ValueList        : {
        $Type         : 'Common.ValueListType',
        Label         : 'parent',
        CollectionPath: 'Genres',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: parent_ID,
            ValueListProperty: 'ID'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
      parent_ID           : Integer;

      @cds.ambiguous           : 'missing on condition?'
      children            : Composition of many CatalogService.Genres;

      @Common.FieldControl     : nodeType_FC
      @Common.Label            : 'nodeType'
      @Validation.AllowedValues: [
        {
          $Type             : 'Validation.AllowedValue',
          @Core.SymbolicName: 'requested',
          Value             : 'F'
        },
        {
          $Type             : 'Validation.AllowedValue',
          @Core.SymbolicName: 'pending',
          Value             : 'L'
        }
      ]
      nodeType            : String(1) default 'F';

      @Core.Computed           : true
      @Common.Label            : 'nodeType_FC'
      nodeType_FC         : Integer;

      @Core.Computed           : true
      @Common.Label            : 'SemanticObject'
      genreSemanticObject : LargeString;

      @cds.ambiguous           : 'missing on condition?'
      texts               : Composition of many CatalogService.Genres_texts;

      @cds.ambiguous           : 'missing on condition?'
      localized           : Association to one CatalogService.Genres_texts
                              on localized.ID = ID;
};

@cds.external        : true
@cds.persistence.skip: true
@UI.Identification   : [{
  $Type: 'UI.DataField',
  Value: name
}]
entity CatalogService.Currencies {
      @Common.Label            : 'Name'
      name          : String(255);

      @Common.Label            : 'Description'
      descr         : String(1000);

      @CodeList.StandardCode   : 'code'
      @Common.UnitSpecificScale: decimalPlaces
      @Common.Text             : name
      @Common.Label            : 'Currency Code'
  key code          : String(3) not null;

      @Common.Label            : 'Currency Symbol'
      symbol        : String(5);

      @Common.Label            : 'Currency Minor Unit Fractions'
      minorUnit     : Integer;
      decimalPlaces : Integer;

      @cds.ambiguous           : 'missing on condition?'
      texts         : Composition of many CatalogService.Currencies_texts;

      @cds.ambiguous           : 'missing on condition?'
      localized     : Association to one CatalogService.Currencies_texts
                        on localized.code = code;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.BookPlants {
      @odata.Precision : 7
      @odata.Type      : 'Edm.DateTimeOffset'
      @UI.HiddenFilter : true
      @Core.Immutable  : true
      @Core.Computed   : true
      @Common.Label    : 'Created On'
      createdAt       : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter : true
      @Core.Immutable  : true
      @Core.Computed   : true
      @Common.Label    : 'Created By'
      createdBy       : String(255);

      @odata.Precision : 7
      @odata.Type      : 'Edm.DateTimeOffset'
      @UI.HiddenFilter : true
      @Core.Computed   : true
      @Common.Label    : 'Changed On'
      modifiedAt      : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter : true
      @Core.Computed   : true
      @Common.Label    : 'Changed By'
      modifiedBy      : String(255);

      @cds.ambiguous   : 'missing on condition?'
      book            : Association to one CatalogService.Books
                          on book.ID = book_ID;
  key book_ID         : Integer not null;

      @cds.ambiguous   : 'missing on condition?'
      plant           : Association to one CatalogService.Plant
                          on plant.ID = plant_ID;

      @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        Label         : 'Plant',
        CollectionPath: 'Plant',
        Parameters    : [
          {
            $Type            : 'Common.ValueListParameterInOut',
            LocalDataProperty: plant_ID,
            ValueListProperty: 'ID'
          },
          {
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
          }
        ]
      }
  key plant_ID        : String(4) not null;
      purchasingGroup : String(3);
};

@cds.external        : true
@cds.persistence.skip: true
@UI.Identification   : [{
  $Type: 'UI.DataField',
  Value: name
}]
entity CatalogService.Countries {
      @Common.Label : 'Name'
      name      : String(255);

      @Common.Label : 'Description'
      descr     : String(1000);

      @Common.Text  : name
      @Common.Label : 'Country/Region Code'
  key code      : String(3) not null;

      @cds.ambiguous: 'missing on condition?'
      texts     : Composition of many CatalogService.Countries_texts;

      @cds.ambiguous: 'missing on condition?'
      localized : Association to one CatalogService.Countries_texts
                    on localized.code = code;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.OrderItems {
  key ID        : UUID not null;

      @cds.ambiguous: 'missing on condition?'
      parent    : Association to one CatalogService.Orders
                    on parent.ID = parent_ID;
      parent_ID : UUID not null;

      @Common.Label : 'itemNo'
      itemNo    : Integer not null;

      @cds.ambiguous: 'missing on condition?'
      book      : Association to one CatalogService.Books
                    on book.ID = book_ID;
      book_ID   : Integer;
      product   : String(10);
      amount    : Integer;
      netAmount : Decimal(9, 2);
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.OrderShippingAddress {
  key ID         : UUID not null;

      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Immutable : true
      @Core.Computed  : true
      @Common.Label   : 'Created On'
      createdAt  : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter: true
      @Core.Immutable : true
      @Core.Computed  : true
      @Common.Label   : 'Created By'
      createdBy  : String(255);

      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Computed  : true
      @Common.Label   : 'Changed On'
      modifiedAt : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter: true
      @Core.Computed  : true
      @Common.Label   : 'Changed By'
      modifiedBy : String(255);

      @UI.Placeholder : 'Street / House No.'
      @Common.Label   : 'Street'
      street     : String(60);

      @Common.Label   : 'City'
      city       : String(60);
};

@cds.external        : true
@cds.persistence.skip: true
@UI.Identification   : [{
  $Type: 'UI.DataField',
  Value: name
}]
entity CatalogService.Orderstatuses {
      @Common.Label : 'Name'
      name      : String(255);

      @Common.Label : 'Description'
      descr     : String(1000);
  key code      : String(1) not null;

      @cds.ambiguous: 'missing on condition?'
      texts     : Composition of many CatalogService.Orderstatuses_texts;

      @cds.ambiguous: 'missing on condition?'
      localized : Association to one CatalogService.Orderstatuses_texts
                    on localized.code = code;
};

@cds.external        : true
@cds.persistence.skip: true
@UI.Identification   : [{
  $Type: 'UI.DataField',
  Value: name
}]
entity CatalogService.Deliverystatuses {
      @Common.Label : 'Name'
      name      : String(255);

      @Common.Label : 'Description'
      descr     : String(1000);
  key code      : String(1) not null;

      @cds.ambiguous: 'missing on condition?'
      texts     : Composition of many CatalogService.Deliverystatuses_texts;

      @cds.ambiguous: 'missing on condition?'
      localized : Association to one CatalogService.Deliverystatuses_texts
                    on localized.code = code;
};

@cds.external        : true
@cds.persistence.skip: true
@Common.SemanticKey  : ['ID']
@UI.Identification   : [{
  $Type: 'UI.DataField',
  Value: name
}]
entity CatalogService.Plant {
      @Common.Label   : 'Name'
      name       : String(255);

      @Common.Label   : 'Description'
      descr      : String(1000);

      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Immutable : true
      @Core.Computed  : true
      @Common.Label   : 'Created On'
      createdAt  : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter: true
      @Core.Immutable : true
      @Core.Computed  : true
      @Common.Label   : 'Created By'
      createdBy  : String(255);

      @odata.Precision: 7
      @odata.Type     : 'Edm.DateTimeOffset'
      @UI.HiddenFilter: true
      @Core.Computed  : true
      @Common.Label   : 'Changed On'
      modifiedAt : Timestamp;

      /**
       * User's unique ID
       */
      @UI.HiddenFilter: true
      @Core.Computed  : true
      @Common.Label   : 'Changed By'
      modifiedBy : String(255);
  key ID         : String(4) not null;

      @cds.ambiguous  : 'missing on condition?'
      texts      : Composition of many CatalogService.Plant_texts;

      @cds.ambiguous  : 'missing on condition?'
      localized  : Association to one CatalogService.Plant_texts {};
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Books_texts {
      @Common.Label                   : 'Language Code'
  key locale : String(14) not null;

      @Common.Text                    : title
      @Common.Text.@UI.TextArrangement: #TextFirst
      @Common.Label                   : 'ID'
  key ID     : Integer not null;

      @Common.Label                   : 'Title'
      title  : String(111);

      @UI.MultiLineText               : true
      descr  : String(1111);
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Genres_texts {
      @Common.Label         : 'Language Code'
  key locale : String(14) not null;

      @Common.Label         : 'Name'
      name   : String(255);

      @Common.Label         : 'Description'
      descr  : String(1000);

      @Common.SemanticObject: genreSemanticObject
      @Common.Label         : 'genreID'
  key ID     : Integer not null;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Currencies_texts {
      @Common.Label            : 'Language Code'
  key locale : String(14) not null;

      @Common.Label            : 'Name'
      name   : String(255);

      @Common.Label            : 'Description'
      descr  : String(1000);

      @CodeList.StandardCode   : 'code'
      @Common.UnitSpecificScale: decimalPlaces
      @Common.Text             : name
      @Common.Label            : 'Currency Code'
  key code   : String(3) not null;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Countries_texts {
      @Common.Label: 'Language Code'
  key locale : String(14) not null;

      @Common.Label: 'Name'
      name   : String(255);

      @Common.Label: 'Description'
      descr  : String(1000);

      @Common.Text : name
      @Common.Label: 'Country/Region Code'
  key code   : String(3) not null;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Orderstatuses_texts {
      @Common.Label: 'Language Code'
  key locale : String(14) not null;

      @Common.Label: 'Name'
      name   : String(255);

      @Common.Label: 'Description'
      descr  : String(1000);
  key code   : String(1) not null;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Deliverystatuses_texts {
      @Common.Label: 'Language Code'
  key locale : String(14) not null;

      @Common.Label: 'Name'
      name   : String(255);

      @Common.Label: 'Description'
      descr  : String(1000);
  key code   : String(1) not null;
};

@cds.external        : true
@cds.persistence.skip: true
entity CatalogService.Plant_texts {
  key ID_texts : UUID not null;

      @Common.Label: 'Language Code'
      locale   : String(14);

      @Common.Label: 'Name'
      name     : String(255);

      @Common.Label: 'Description'
      descr    : String(1000);
      ID       : String(4);
};

@cds.external: true
type CatalogService.DynamicAppLauncher {
  icon         : LargeString;
  info         : LargeString;
  infoState    : LargeString;
  number       : Decimal(9, 2);
  numberDigits : Integer;
  numberFactor : LargeString;
  numberState  : LargeString;
  numberUnit   : LargeString;
  stateArrow   : LargeString;
  subtitle     : LargeString;
  title        : LargeString;
};

@cds.external: true
service CatalogService {};
