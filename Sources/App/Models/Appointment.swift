import Fluent
import Vapor

final class Appointment: Model, Content {
    static let schema = "appointment"

    struct FieldKeys {
        static var hospitalID: FieldKey { "hospital_id" }
        static var time: FieldKey { "time" }
        static var patientID: FieldKey { "patient_id" }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.hospitalID)
    var hospital: Hospital

    @Field(key: FieldKeys.time)
    var time: Date

    @Parent(key: FieldKeys.patientID)
    var patient: Patient

    init() { }

    init(
        id: UUID? = nil,
        time: Date,
        hospitalID: UUID,
        patientID: UUID
    ) {
        self.id = id
        self.time = time
        $hospital.id = hospitalID
        $patient.id = patientID
    }
}
