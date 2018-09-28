import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // Register the new controller instance with the router to hook up the routes.
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    // Register the new controller instance with the router to hook up the routes.
    let usersController = UsersController()
    try router.register(collection: usersController)
    
}
