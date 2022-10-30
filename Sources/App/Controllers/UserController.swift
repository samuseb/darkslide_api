import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: getAll)
        users.post(use: create)
        users.put(use: update)

        users.group(":userUID") { user in
            user.get(use: getByUserUID)
            user.delete(use: delete)
        }
    }

    // GET /users
    func getAll(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    // GET /users/:userUID
    func getByUserUID(req: Request) throws -> EventLoopFuture<User> {
        let userUID = req.parameters.get("userUID")
        return User.query(on: req.db)
            .filter(\.$userUID == userUID ?? "")
            .first()
            .unwrap(or: Abort(.notFound))
    }

    // POST /users
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus>{
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).transform(to: .ok)
    }

    // PUT /users
    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.content.decode(User.self)
        return User.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.userName = user.userName
                $0.coverPhotoData = user.coverPhotoData
                $0.bioDescription = user.bioDescription
                return $0.update(on: req.db).transform(to: .ok)
            }
    }

    // DELETE /users/:userUID
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let UID = req.parameters.get("userUID") ?? ""
        return User.query(on: req.db)
            .filter(\.$userUID == UID)
            .delete()
            .transform(to: .ok)
    }
}
