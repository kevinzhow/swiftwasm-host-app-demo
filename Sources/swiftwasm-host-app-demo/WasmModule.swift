import Foundation
import WasmInterpreter
import SwiftProtobuf

public struct WasmModule {
    private let _vm: WasmInterpreter

    init() throws {
        _vm = try WasmInterpreter(module: Bundle.module.url(forResource: "swiftwasm", withExtension: "wasm")!)
    }

    /// Allocate memory on heap
    /// It returns byteoffset
    func allocate(size: Int) throws -> Int {
        return Int(try _vm.call("allocate", Int32(size)) as Int32)
    }
    
    func deallocate(byteOffset: Int) throws {
        try _vm.call("deallocate", Int32(byteOffset))
    }
    
    /// Allocate size on heap
    /// It returns byteoffset
    func allocateSize() throws -> Int {
        
        let length = MemoryLayout<Int32>.size
        
        let newSizePointer = try! allocate(size: length)
        
        return newSizePointer
    }
    
    /// Write string to heap
    /// It returns byteoffset
    func writeString(string: String) throws -> (Int, Int) {
        
        let length = Data(string.utf8).count
        
        let pointer = try! allocate(size: length)
        
        try _vm.writeToHeap(string: string, byteOffset: pointer)
        
        return (pointer, length)
    }
    
    /// Write Data to heap
    /// It returns byteoffset
    func writeData(data: Data) throws -> Int {
        
        let length = data.count
        
        let pointer = try! allocate(size: length)
        
        try _vm.writeToHeap(data: data, byteOffset: pointer)

        return pointer
    }

    /// Send Protobuf binary into
    func changeBook(_ book: BookInfo, author: String) throws -> BookInfo {
         let data = try! book.serializedData()
        
        let (newAuthorPtr, newAuthorSize) = try! writeString(string: author)
        
        let newSizePointer = try! allocateSize()
        
        let dataPointer = try writeData(data: data)
        
        let newArticlePointer = Int(try _vm.call("change_article_proto",
                                                 Int32(dataPointer),
                                                 Int32(data.count),
                                                 Int32(newAuthorPtr),
                                                 Int32(newAuthorSize),
                                                 Int32(newSizePointer)) as Int32)
        
        let newSizeValue = Int(try _vm.valueFromHeap(byteOffset: newSizePointer) as Int32)
        
        let newData = try _vm.dataFromHeap(byteOffset: newArticlePointer, length: newSizeValue)
        
        let newBook = try! BookInfo(serializedData: newData)
        
        try! deallocate(byteOffset: newAuthorPtr)
        try! deallocate(byteOffset: newSizePointer)
        try! deallocate(byteOffset: dataPointer)
        try! deallocate(byteOffset: newArticlePointer)
        
        return newBook
    }
}
