sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'cds/demo/mtxs/books/test/integration/FirstJourney',
		'cds/demo/mtxs/books/test/integration/pages/BooksList',
		'cds/demo/mtxs/books/test/integration/pages/BooksObjectPage'
    ],
    function(JourneyRunner, opaJourney, BooksList, BooksObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('cds/demo/mtxs/books') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheBooksList: BooksList,
					onTheBooksObjectPage: BooksObjectPage
                }
            },
            opaJourney.run
        );
    }
);