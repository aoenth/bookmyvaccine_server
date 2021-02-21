import Fluent
import Vapor

struct AppointmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let models = routes.grouped("appointments")
        models.get(use: index)
        models.post(use: create)
        models.group(":appointmentId") { model in
            model.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Appointment]> {
        return Appointment.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Appointment> {
        let hospitalID = try req.content.get(UUID.self, at: "hospital")
        let patientID = try req.content.get(UUID.self, at: "patient")
        let time = try req.content.get(Date.self, at: "time")
        let appointment = Appointment(time: time, hospitalID: hospitalID, patientID: patientID)
        return appointment.save(on: req.db).map { appointment }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Appointment.find(req.parameters.get("appointmentId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
