using my.bookshop as my from '../db/data-model';

service BooksApiService {
    entity Books as
        projection on my.Books
        excluding {
            author
        };
}

annotate BooksApiService.Books with {
    modifiedAt @odata.etag
}
