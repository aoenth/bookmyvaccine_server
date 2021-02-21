import Fluent
import Vapor

final class Hospital: Model, Content {
    static let schema = "hospital"

    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var latitude: FieldKey { "latitude" }
        static var longitude: FieldKey { "longitude" }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.name)
    var name: String

    @Children(for: \.$hospital)
    var appointments: [Appointment]

    @Field(key: FieldKeys.latitude)
    var latitude: Double

    @Field(key: FieldKeys.longitude)
    var longitude: Double

    init() { }

    init(id: UUID? = nil, name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
