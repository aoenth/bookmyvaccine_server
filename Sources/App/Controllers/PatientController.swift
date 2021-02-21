import Fluent
import Vapor

struct HospitalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("hospitals")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":hospitalId") { todo in
            todo.delete(use: delete)
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
