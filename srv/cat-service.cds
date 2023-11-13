using my.bookshop as my from '../db/data-model';

service CatalogService {
    @odata.draft.enabled
    entity Books   as projection on my.Books;

    entity Authors as projection on my.Authors;

    @readonly
    entity CS1TAB  as projection on my.CS1TAB;
}
// Annotations for value help

annotate CatalogService.Books with {
    author @(Common.ValueList: {
        Label         : 'Authors',
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
    });
}

annotate CatalogService.Authors with {
    ID @(
        title : 'ID',
        Common: {Text: {
            $value             : name,
            @UI.TextArrangement: #TextOnly
        }}
    );
}

annotate CatalogService.Authors with @Capabilities.SearchRestrictions.Searchable: false;
