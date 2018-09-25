import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Create an Acronym
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
    }
    
    // Retrieve all Acronyms
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req)
                      .all()
    }
    
    // Retrieve a single Acronym
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    // Update an Acronym
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),   // obtiene el acronym de la base de datos (como en 'Retrieve a single Acronym' )
                           req.content.decode(Acronym.self)     // este crea un acronym con los parametros enviados (como en 'Create an Acronym' )
        ) { acronym, updatedAcronym in
            
            // 'acronym' es el objeto obtenido en la base de datos
            // 'updatedAcronym' es el objeto creado con los parametros enviados
            
            // actualizamos el acronym con los datos del nuevo
            acronym.short = updatedAcronym.short
            acronym.long  = updatedAcronym.long
                            
            // guardamos el acronym actualizado y lo devolvemos en un Future<Acronym>
            return acronym.save(on: req)
        }
    }
    
    // Delete an Acronym
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        
        return try req.parameters.next(Acronym.self) // Extraemos el 'acronym' que se va borrar de los parametros del request
                                 .delete(on: req)    // Borramos el 'acronym' usando 'delete(on:)'
                                 .transform(to: HTTPStatus.noContent)
        
    }
    
    // Search for acronyms
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        
        // Retrieve the search term from the URL query string.
        guard let searchTerm = req.query[String.self, at:"term"] else { throw Abort(.badRequest) }
        
        // on single field
//        return Acronym.query(on: req)
//                      // usamos 'filter(_:)' para encontrar todos los 'acronyms' donde la porperty 'short' sea igual a 'searchTerm'
//                      .filter(\.short == searchTerm)
//                      .all()
        
        // on multiple fields
        return Acronym.query(on: req).group(.or) { or in // creamos un grupo de filtros con relacion '.or'
            or.filter(\.short == searchTerm)             // agregamos al grupo un filtro cuya property 'short' sea igual al 'searchTerm'
            or.filter(\.long == searchTerm)              // agregamos al grupo un filtro cuya property 'long' sea igual al 'searchTerm'
        }.all()                                          // retornamos todos los resultados
        
    }
    
    // Retrieve the First Acronym
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        
        return Acronym.query(on: req)
                      .first()                              // realizamos la query para traer el primer 'accronym'
                      .map(to: Acronym.self) { acronym in   // usamos la funcion map(to:) to unwrapear el resultado de la query (por que viene en un FUTURE)
                        
                        guard let acronym = acronym else { throw Abort(.notFound) } // aseguramos que el 'acronym' exista, first() retorna un optional(?)
                        return acronym
        }
    }
    
    // Sorting Results
    router.get("api", "acronyms", "sorted") { req -> Future<[Acronym]> in
        return Acronym.query(on: req)
                      .sort(\.short, .ascending)
                      .all()
    }
    
    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
