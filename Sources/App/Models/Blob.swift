import FluentSQLite
import Vapor

/// A single entry of a Todo list.
struct Blob: SQLiteModel {
    var id: Int?
    var hash: SHA256
    lazy var data: Data = try! Blob.read(self.hash)
    
    init(withData data: Data) throws {
        self.hash = try Blob.write(data)
    }
    
    static func write(_ data: Data) throws -> SHA256 {
        let hash = SHA256(withData: data)
        try FileManager.default.createDirectory(atPath: "/Users/jack/.papyri/obj/\(getDBPrefixDirPath(hash))", withIntermediateDirectories: true)
        print(String(data: data, encoding: .utf8)!)
        do {
        try data.write(to: urlForHash(hash))
        } catch {
            print(error)
        }
    
        return hash
    }
    
    static func read(_ hash: SHA256) throws -> Data {
        return try Data(contentsOf: urlForHash(hash))
    }
    
    static func urlForHash(_ hash: SHA256) -> URL {
        return URL(fileURLWithPath: "/Users/jack/.papyri/obj/\(getDBPathForHash(hash))")
    }
    
    static func getDBPathForHash(_ sha: SHA256) -> String {
        let hex = sha.hex
        let splitIndex = hex.index(hex.startIndex, offsetBy: 2)
        let part1 = hex.prefix(upTo: splitIndex)
        let part2 = hex.suffix(from: splitIndex)
        return "\(part1)/\(part2)"
    }
    
    static func getDBPrefixDirPath(_ sha: SHA256) -> String {
        let hex = sha.hex
        let splitIndex = hex.index(hex.startIndex, offsetBy: 2)
        let part1 = hex.prefix(upTo: splitIndex)
        return String(part1)
    }
}

extension Blob: Migration { }

extension Blob: Content { }

extension Blob: Parameter { }