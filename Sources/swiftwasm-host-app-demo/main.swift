
import WasmInterpreter
print("Hello, world!")

let module = try! WasmModule()
var book = BookInfo()
book.id = 1
book.author = "Apple"
book.title = "Swift Programming"
let newBook = try! module.changeBook(book, author: "Apple Stuff")
print(newBook.author)