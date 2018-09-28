import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        // Esto es un 'Route Group'
        /*
         If you need to change the /api/acronyms/ path, you have to change the path in multiple locations.
         If you add a new route, you have to remember to add both parts of the path. Vapor provides route groups to simplify this.
         */
        let acronymsRoutes = router.grouped("api", "acronyms")
        
        // Registramos las 'routes'
        acronymsRoutes.get(use: getAllHandler)                              // GET request to '/api/acronyms/'
        acronymsRoutes.post(use: createHandler)                             // POST request to '/api/acronyms'
        acronymsRoutes.get(Acronym.parameter, use: getHandler)              // GET request to '/api/acronyms/<ACRONYM_ID>'
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)           // PUT request to '/api/acronyms/<ACRONYM_ID>'
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)        // DELETE request to '/api/acronyms/<ACRONYM_ID>'
        acronymsRoutes.get("search", use: searchHandler)                    // GET request to '/api/acronyms/search'
        acronymsRoutes.get("first", use: getFirstHandler)                   // GET request to '/api/acronyms/first'
        acronymsRoutes.get("sorted", use: sortedHandler)                    // GET request to '/api/acronyms/sorted'
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)  // GET request to '/api/acronyms/<ACRONYM_ID>/user'
    }
    
    // Retrieve all Acronyms
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req)
                      .all()
    }
    
    // Create an Acronym
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self)
                              .flatMap(to: Acronym.self) { acronym in
                                return acronym.save(on: req)
                              }
    }
    
    // Retrieve a single Acronym
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    // Update an Acronym
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self), // obtiene el acronym de la base de datos (como en 'Retrieve a single Acronym' )
                           req.content.decode(Acronym.self)   // este crea un acronym con los parametros enviados (como en 'Create an Acronym' )
        ) { acronym, updatedAcronym in
            
            // 'acronym' es el objeto obtenido en la base de datos
            // 'updatedAcronym' es el objeto creado con los parametros enviados
            
            // actualizamos el acronym con los datos del nuevo
            acronym.short  = updatedAcronym.short
            acronym.long   = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            
            // guardamos el acronym actualizado y lo devolvemos en un Future<Acronym>
            return acronym.save(on: req)
        }
    }
    
    // Delete an Acronym
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)    // Extraemos el 'acronym' que se va borrar de los parametros del request
                                 .delete(on: req)       // Borramos el 'acronym' usando 'delete(on:)'
                                 .transform(to: HTTPStatus.noContent)
    }
    
    // Search for acronyms
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        // Retrieve the search term from the URL query string.
        guard let searchTerm = req.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        
        // on single field
        // usamos 'filter(_:)' para encontrar todos los 'acronyms' donde la porperty 'short' sea igual a 'searchTerm'
        //return Acronym.query(on: req).filter(\.short == searchTerm).all()
        
        // on multiple fields
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    // Retrieve the First Acronym
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req)
                      .first()                              // realizamos la query para traer el primer 'accronym'
                      .map(to: Acronym.self) { acronym in   // usamos la funcion map(to:) to unwrapear el resultado de la query (por que viene en un FUTURE)
                        
                        guard let acronym = acronym else { throw Abort(.notFound) } // aseguramos que el 'acronym' exista, first() retorna un optional(?)
                        return acronym
                      }
    }
    
    // Sorting Results
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req)
                      .sort(\.short, .ascending)
                      .all()
    }
    
    // Retrieve User
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
                                 .flatMap(to: User.self) { acronym in
                                    acronym.user.get(on: req)
                                 }
    }
}
