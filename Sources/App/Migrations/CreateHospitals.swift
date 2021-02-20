import Fluent

struct CreateHospital: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("hospital")
            .id()
            .field("name", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("hospital").delete()
    }
}
