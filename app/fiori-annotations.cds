using {CatalogService} from '../srv/cat-service';

annotate CatalogService.Books with @UI: {
  SelectionFields : [
    title,
    author_ID
  ],
  LineItem        : [
    {Value: title},
    {Value: stock},
    {Value: author.name},
  ],
  Facets          : [{
    $Type : 'UI.ReferenceFacet',
    Label : 'Main',
    Target: '@UI.FieldGroup#Main'
  }],
  FieldGroup #Main: {Data: [
    {Value: title},
    {Value: stock},
    {Value: author_ID}
  ]}
};
