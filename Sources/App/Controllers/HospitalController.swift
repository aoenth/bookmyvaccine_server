import Fluent
import Vapor

struct HospitalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let models = routes.grouped("hospitals")
        models.get(use: index)
        models.get("appointments", use: getHospitalsOrByName)
        models.post(use: create)
        models.group(":hospitalId") { model in
            model.delete(use: delete)
            model.get(use: getHospital)
        }
    }

    func getHospital(req: Request) throws -> EventLoopFuture<[Appointment]> {
        Hospital.find(req.parameters.get("hospitalId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { hospital -> EventLoopFuture<[Appointment]> in
                Appointment.query(on: req.db)
                    .filter(\.$hospital.$id == hospital.id!)
                    .all()
            }
    }

    func getHospitalsOrByName(req: Request) throws -> EventLoopFuture<[Appointment]> {
        let hospitalName = try req.query.get(String.self, at: "hospitalName")
        return Hospital.query(on: req.db)
            .filter(\.$name == hospitalName)
            .first()
            .unwrap(or: Abort(.noContent))
            .flatMap { hospital -> EventLoopFuture<[Appointment]> in
                Appointment.query(on: req.db)
                    .filter(\.$hospital.$id == hospital.id!)
                    .all()
            }
    }

    func index(req: Request) throws -> EventLoopFuture<[Hospital]> {
        return Hospital.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Hospital> {
        let hospital = try req.content.decode(Hospital.self)
        return hospital.save(on: req.db).map { hospital }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Hospital.find(req.parameters.get("hospitalId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
