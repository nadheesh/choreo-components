import ballerina/http;

type Author record {
    string name;
    string nationality;
};

type Book record {
    string title;
    Author author;
    int year;
    string isbn;
};

type BookRecord record {
    readonly int id;
    Book book;
};

table<BookRecord> key(id) library = table [
    {id: 1, book: {title: "The Da Vinci Code", author: {name: "Dan Brown", nationality: "American"}, year: 2003, isbn: "030-7474-275"}},
    {id: 2, book: {title: "The Great Gatsby", author: {name: "F. Scott Fitzgerald", nationality: "American"}, year: 1925, isbn: "010-7574-272"}},
    {id: 3, book: {title: "Jane Eyre", author: {name: "Charlotte Bronte", nationality: "British"}, year: 1847, isbn: "130-4574-675"}}
];

# A service representing a network-accessible API
# bound to port `8080`.
service / on new http:Listener(8080) {

    # A resource for getting details of a book
    # + bookId - the title of the book to be retrieved
    # + return - the book with the given title or error
    resource function get book(int bookId) returns error|BookRecord {
        return library.hasKey(bookId) ? library.get(bookId) : error("Book not found");
    }

    # A resource to get details of all the books
    # + return - all the books in the library
    resource function get books()  returns error|BookRecord[] {
        return library.toArray();
    }

    # A resource for getting the books with a given title
    # + bookTitle - the title of the books to be retrieved
    # + return - the books with the given title
    resource function get booksByTitle(string bookTitle) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.title.toLowerAscii() == bookTitle.toLowerAscii();
        }).toArray();
    }
    
    # A resource for getting the books published in a given year
    # + year - the year of the books to be retrieved
    # + return - the books published in the given year
    resource function get booksByYear(int year) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.year == year;
        }).toArray();
    }

    # A resource for getting the books written by a given author
    # + authorName - the name of the author of the books to be retrieved
    # + return - the books written by the given author
    resource function get booksByAuthor(string authorName) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.author.name.toLowerAscii() == authorName.toLowerAscii();
        }).toArray();
    }

    # A resource for adding a book
    # + book - the book to be added
    # + return - string message or error
    resource function post book(@http:Payload Book book) returns error|string {
        if library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.title.toLowerAscii() == book.title.toLowerAscii() && bookRecord.book.author.name.toLowerAscii() == book.author.name.toLowerAscii();
        }).toArray().length() > 0 {
            return error("A book with same title and author already exists");
        }
        else {
            int id = library.nextKey();
            library.add({id, book});
            return "Successfully added book: " + book.title;
        }
    }

    # A resource to delete a book
    # + bookId - the id of the book to be deleted
    # + return - string message or error
    resource function delete book(int bookId) returns error|string {
        if (library.hasKey(bookId)) {
            BookRecord bookRecord = library.remove(bookId);
            return "Successfully deleted book: " + bookRecord.book.title;

        }
        else {
            return error("Book not found");
        }
    }

    # A resource for updating the details of a book
    # + bookId - the id of the book to be updated
    # + book - the book to be updated
    # + return - string message or error
    resource function put book(int bookId, @http:Payload Book book) returns error|string {
        if (library.hasKey(bookId)) {
            _ = library.put({id: bookId, book});
            return "Successfully updated book: " + book.title;

        } else {
            return error("Book not found");
        }
    }

    # A resource for checking if a book exists
    # + bookTitle - the title of the book to be checked
    # + return - boolean value indicating whether the book exists or not
    resource function get hasBook(string bookTitle) returns error|boolean {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.title.toLowerAscii() == bookTitle.toLowerAscii();
        }).toArray().length() > 0;
    }

    # A resource for counting the number of books
    # + return - the number of books in the library
    resource function get countBooks() returns error|int {
        return library.length();
    }   
}