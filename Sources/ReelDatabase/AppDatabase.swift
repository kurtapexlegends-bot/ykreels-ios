import Foundation
import GRDB
import ReelCore

/// SQLite database coordinator powered by GRDB.swift.
/// Runs in Write-Ahead Logging (WAL) mode with foreign keys enabled.
public final class AppDatabase: Sendable {
    private let dbWriter: any DatabaseWriter

    /// Shared application database coordinator.
    public static let shared: AppDatabase = {
        do {
            return try openDatabase()
        } catch {
            return (try? makeInMemory()) ?? (try! AppDatabase(DatabaseQueue()))
        }
    }()

    public var reader: any DatabaseReader { dbWriter }
    public var writer: any DatabaseWriter { dbWriter }

    public init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try setupDatabase()
    }

    private func setupDatabase() throws {
        var migrator = DatabaseMigrator()
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = false
        #endif
        SchemaMigrations.registerMigrations(in: &migrator)
        try migrator.migrate(dbWriter)
    }

    /// Factory method for production on-device SQLite database.
    public static func openDatabase(at path: String? = nil) throws -> AppDatabase {
        let databaseURL: URL
        if let path = path {
            databaseURL = URL(fileURLWithPath: path)
        } else {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directoryURL = appSupport.appendingPathComponent("YKReels", isDirectory: true)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            databaseURL = directoryURL.appendingPathComponent("ykreels.sqlite")
        }

        var config = Configuration()
        config.qos = .userInitiated
        config.foreignKeysEnabled = true
        config.label = "com.ykreels.database"

        let dbPool = try DatabasePool(path: databaseURL.path, configuration: config)
        return try AppDatabase(dbPool)
    }

    /// Factory method for ephemeral in-memory database used in unit tests.
    public static func makeInMemory() throws -> AppDatabase {
        var config = Configuration()
        config.foreignKeysEnabled = true
        config.label = "com.ykreels.database.inmemory"
        let dbQueue = try DatabaseQueue(configuration: config)
        return try AppDatabase(dbQueue)
    }
}
