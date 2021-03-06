import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    
    var id      :Int?
    var short   :String
    var long    :String
    var userID  :User.ID
    
    init(short:String, long:String, userID: User.ID) {
        self.short  = short
        self.long   = long
        self.userID = userID
    }
    
}

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}

extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

//extension Acronym: Model {
//
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
//
//}

// MARK: SQLiteModel implementation
// Al implementar SQLiteModel, hacemos lo mismo que el codigo que esta arriba
// En el caso que el ID del modelo sea de otro tipo tenemos SQLiteUUIDModel y SQLiteStringModel
//extension Acronym: SQLiteModel {}
extension Acronym: PostgreSQLModel {}

extension Acronym: Content {}
extension Acronym: Parameter {}

