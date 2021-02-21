import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let controllers: [RouteCollection] = [
        HospitalController(),
        PatientController(),
        AppointmentController()
    ]
    for controller in controllers {
        try app.register(collection: controller)
    }
}
