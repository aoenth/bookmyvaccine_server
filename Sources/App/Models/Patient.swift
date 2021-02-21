import Fluent
import Vapor

final class Patient: Model, Content {
    static let schema = "patient"

    struct FieldKeys {
        static var name: FieldKey { "name" }
    }

    @ID()
    var id: UUID?

    @Children(for: \.$patient)
    var appointments: [Appointment]

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, name: String, appointments: [Appointment]) {
        self.id = id
        self.appointments = appointments
        self.name = name
    }
}
