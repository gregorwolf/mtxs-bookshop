using my.bookshop as my from '../db/data-model';

service CatalogService {
    entity Books  as projection on my.Books;

    @readonly
    entity CS1TAB as projection on my.CS1TAB;
}
