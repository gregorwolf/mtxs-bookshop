using {CatalogService} from '../srv/cat-service';

annotate CatalogService.Books with @UI: {
  SelectionFields: [title],
  LineItem       : [
    {Value: ID},
    {Value: title},
    {Value: stock}
  ],
};
