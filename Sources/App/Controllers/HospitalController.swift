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
            .flatMap { hospital -> EventLoopFuture<[Appointment]> in
                let id = hospital?.id ?? UUID()
                return Appointment.query(on: req.db)
                    .filter(\.$hospital.$id == id)
                    .all()
            }
    }

    func index(req: Request) throws -> EventLoopFuture<[Hospital]> {
        return Hospital.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Hospital> {
        let latitude = try req.content.get(Double.self, at: "latitude")
        let longitude = try req.content.get(Double.self, at: "longitude")
        let name = try req.content.get(String.self, at: "name")
        return Hospital.query(on: req.db)
            .filter(\.$latitude == latitude)
            .filter(\.$longitude == longitude)
            .all()
            .flatMap { hosptalsFound -> EventLoopFuture<Hospital> in
                if let first = hosptalsFound.first {
                    return req.eventLoop.makeSucceededFuture(first)
                } else {
                    let newHospital = Hospital(name: name, latitude: latitude, longitude: longitude)
                    return newHospital
                        .save(on: req.db)
                        .map { newHospital }
                }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Hospital.find(req.parameters.get("hospitalId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
