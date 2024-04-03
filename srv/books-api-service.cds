using my.bookshop as my from '../db/data-model';

@(requires: 'admin')
service BooksApiService {
    entity Books as
        projection on my.Books
        excluding {
            author
        };
}

/*
// Deactivate etag so current CAP Client works
annotate BooksApiService.Books with {
    modifiedAt @odata.etag
}
*/
