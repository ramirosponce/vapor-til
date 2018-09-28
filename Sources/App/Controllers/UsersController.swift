import Vapor

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let userRoute = router.grouped("api", "users")
        
        userRoute.post(User.self, use: createHandler)
        userRoute.get(use: getAllHandler)               // GET request to '/api/users'
        userRoute.get(User.parameter, use: getHandler)  // GET request to '/api/users/<USER_ID>'
        userRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)  // GET request to '/api/users/<USER_ID>/acronyms'
    }
    
    // Create a 'User'
    func createHandler(_ req: Request, user:User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    // Retrieve all 'Users'
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req)
                   .all()
    }
    
    // Retrieve a single 'User'
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    // Retrieve 'Acronyms' by 'User'
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self)
                                 .flatMap(to: [Acronym].self) { user in
                                    try user.acronyms.query(on: req).all()
                                 }
    }
    
}
