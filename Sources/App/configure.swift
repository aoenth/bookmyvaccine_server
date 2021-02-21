import Fluent
import FluentPostgresDriver
import Vapor

extension Environment {
    static var databaseURL: URL {
        guard let urlString = Environment.get("DATABASE_URL"),
            let url = URL(string: urlString)
        else {
            fatalError("DATABASE_URL not configured")
        }
        return url
    }

    static var databaseConfiguration: PostgresConfiguration {
        guard var postgresConfig = PostgresConfiguration(url: databaseURL) else {
            fatalError("PostgresConfiguration not configured")
        }
        postgresConfig.tlsConfiguration = .forClient(certificateVerification: .none)
        return postgresConfig
    }
}

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.postgres(url: Environment.databaseURL), as: .psql)

    let migrations: [Migration] = [
        Migration001()
    ]

    app.migrations.add(migrations)
    if app.environment == .development {
        try app.autoMigrate().wait()
    }

    // register routes
    try routes(app)
}
