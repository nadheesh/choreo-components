import ballerina/http;

type Author record {
    string name;
    string nationality;
};

type Book record {
    readonly string title;
    Author author;
    int year;
    string isbn;
};

table<Book> key(title) library = table [
    {title: "The Da Vinci Code", author: {name: "Dan Brown", nationality: "American"}, year: 2003, isbn: "030-7474-275"},
    {title: "The Great Gatsby", author: {name: "F. Scott Fitzgerald", nationality: "American"}, year: 1925, isbn: "010-7574-272"},
    {title: "Jane Eyre", author: {name: "Charlotte Bronte", nationality: "British"}, year: 1847, isbn: "130-4574-675"}
];

# A service representing a network-accessible API
# bound to port `8080`.
service / on new http:Listener(8080) {

    # A resource for getting details of a book
    # + bookTitle - the title of the book to be retrieved
    # + return - the book with the given title or error
    resource function get book(string bookTitle) returns error|Book {
        return library.hasKey(bookTitle) ? library.get(bookTitle) : error("Book not found");
    }

    # A resource to get details of all the books in the library
    # + return - all the books in the library
    resource function get books()  returns error|table<Book> {
        return library;
    }

    # A resource for getting the books published in a given year
    # + year - the year of the books to be retrieved
    # + return - the books published in the given year
    resource function get getBooksByYear(int year) returns error|table<Book> {
        return library.filter(function (Book book) returns boolean {
            return book.year == year;
        });
    }

    # A resource for getting the books written by a given author
    # + authorName - the name of the author of the books to be retrieved
    # + return - the books written by the given author
    resource function get getBooksByAuthor(string authorName) returns error|table<Book> {
        return library.filter(function (Book book) returns boolean {
            return book.author.name == authorName;
        });
    }

    # A resource for adding a book
    # + book - the book to be added
    # + return - string message or error
    resource function post addBook(@http:Payload Book book) returns error|string {
        library.add(book);
        return "successfully added book" + book.title;
    }

    #A resource to delete a book
    # + bookTitle - the title of the book to be deleted
    # + return - string message or error
    resource function delete deleteBook(string bookTitle) returns error|string {
        _ = library.removeIfHasKey(bookTitle);
        return "successfully deleted book" + bookTitle;
    }

    # A resource for updating a book
    # + bookTitle - the title of the book to be updated
    # + book - the book to be updated
    # + return - string message or error
    resource function put updateBook(string bookTitle, @http:Payload Book book) returns error|string {
        if (library.hasKey(bookTitle)) {
            _ = library.put(book);
            return "successfully updated book" + bookTitle;

        } else {
            return error("book not found");
        }
    }

    # A resource for checking if a book exists
    # + bookTitle - the title of the book to be checked
    # + return - boolean value indicating whether the book exists or not
    resource function get hasBook(string bookTitle) returns error|boolean {
        return library.hasKey(bookTitle);
    }

    # A resource for counting the number of books
    # + return - the number of books in the library
    resource function get countBooks() returns error|int {
        return library.length();
    }   
}