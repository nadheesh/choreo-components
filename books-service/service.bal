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

    resource function get book(int bookId) returns error|BookRecord {
        return library.hasKey(bookId) ? library.get(bookId) : error("Book not found");
    }

    resource function get books()  returns error|BookRecord[] {
        return library.toArray();
    }

    resource function get booksByTitle(string bookTitle) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.title.toLowerAscii() == bookTitle.toLowerAscii();
        }).toArray();
    }
    
    resource function get booksByYear(int year) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.year == year;
        }).toArray();
    }

    resource function get booksByAuthor(string authorName) returns error|BookRecord[] {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.author.name.toLowerAscii() == authorName.toLowerAscii();
        }).toArray();
    }

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

    resource function delete book(int bookId) returns error|string {
        if (library.hasKey(bookId)) {
            BookRecord bookRecord = library.remove(bookId);
            return "Successfully deleted book: " + bookRecord.book.title;

        }
        else {
            return error("Book not found");
        }
    }

    resource function put book(int bookId, @http:Payload Book book) returns error|string {
        if (library.hasKey(bookId)) {
            _ = library.put({id: bookId, book});
            return "Successfully updated book: " + book.title;

        } else {
            return error("Book not found");
        }
    }

    resource function get hasBook(string bookTitle) returns error|boolean {
        return library.filter(function (BookRecord bookRecord) returns boolean {
            return bookRecord.book.title.toLowerAscii() == bookTitle.toLowerAscii();
        }).toArray().length() > 0;
    }

    resource function get countBooks() returns error|int {
        return library.length();
    }   
}