import Fluent
import Vapor

struct PatientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let models = routes.grouped("patients")
        models.get(use: index)
        models.post(use: create)
        models.group(":patientId") { model in
            model.delete(use: delete)
            model.get("appointments", use: getPatientAppointments)
        }
    }

    func getPatientAppointments(
        req: Request
    ) throws -> EventLoopFuture<[Appointment]> {
        let patient = Patient.find(req.parameters.get("patientId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let result = patient.flatMap { input in
            Appointment.query(on: req.db)
                .filter(\.$patient.$id == input.id!)
                .all()
        }
        return result
    }

    func index(req: Request) throws -> EventLoopFuture<[Patient]> {
        return Patient.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Patient> {
        let name = try req.content.get(String.self, at: "name")
        let model = try req.content.decode(Patient.self)
        return Patient.query(on: req.db)
            .filter(\.$name == name)
            .all()
            .flatMap { patientsFound -> EventLoopFuture<Patient> in
                if let first = patientsFound.first {
                    return req.eventLoop.makeSucceededFuture(first)
                } else {
                    return model.save(on: req.db).map { model }
                }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Patient.find(req.parameters.get("patientId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
