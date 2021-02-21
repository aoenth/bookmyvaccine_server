import Fluent
import FluentPostgresDriver
import Vapor

extension Environment {
    static var databaseURL: URL {
        guard let urlString = Environment.get(
            "DATABASE_URL"),
            let url = URL(string: urlString)
        else {
            fatalError("DATABASE_URL not configured")
        }
        return url
    }
}

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.postgres(url: Environment.databaseURL), as: .psql)

    let migragions: [Migration] = [
        Migration001()
    ]

    app.migrations.add(migragions)

    // register routes
    try routes(app)
}
