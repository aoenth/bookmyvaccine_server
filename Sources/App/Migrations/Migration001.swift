import Fluent

struct Migration001: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten(
            [
                database.schema(Hospital.schema)
                    .id()
                    .field(Hospital.FieldKeys.name, .string, .required)
                    .field(Hospital.FieldKeys.latitude, .double, .required)
                    .field(Hospital.FieldKeys.longitude, .double, .required)
                    .create(),
                database.schema(Patient.schema)
                    .id()
                    .field(Patient.FieldKeys.name, .string, .required)
                    .create(),
                database.schema(Appointment.schema)
                    .id()
                    .field(Appointment.FieldKeys.hospitalID, .uuid, .required)
                    .foreignKey(
                        Appointment.FieldKeys.hospitalID,
                        references: Hospital.schema,
                        .id,
                        onDelete: DatabaseSchema.ForeignKeyAction.setNull,
                        onUpdate: DatabaseSchema.ForeignKeyAction.cascade
                    )
                    .field(Appointment.FieldKeys.patientID, .uuid, .required)
                    .foreignKey(
                        Appointment.FieldKeys.patientID,
                        references: Patient.schema,
                        .id,
                        onDelete: DatabaseSchema.ForeignKeyAction.setNull,
                        onUpdate: DatabaseSchema.ForeignKeyAction.cascade
                    )
                    .field(Appointment.FieldKeys.time, .date, .required)
                    .create(),
            ]
        )
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Appointment.schema).delete()
    }
}
