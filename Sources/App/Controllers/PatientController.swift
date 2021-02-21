import Fluent
import Vapor

struct PatientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let models = routes.grouped("patients")
        models.get(use: index)
        models.post(use: create)
        models.group(":patientId") { model in
            model.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Patient]> {
        return Patient.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Patient> {
        let model = try req.content.decode(Patient.self)
        return model.save(on: req.db).map { model }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Patient.find(req.parameters.get("patientId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
