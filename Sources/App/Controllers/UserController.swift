import Fluent
import Foundation
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

            user.group("username") { user2 in
                user2.get(use: getUserName)
            }
        }

        users.group("exists") { user in
            user.group(":username") { user2 in
                user2.get(use: exists)
            }
        }
    }

    // GET /users
    // optional query params: search
    func getAll(req: Request) throws -> EventLoopFuture<[User]> {
        let search = try req.query.decode(Search.self)
        let paging = try req.query.decode(Paging.self)
        if let search = search.search {
            if let page = paging.page, let limit = paging.limit {
                let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)
                return User.query(on: req.db)
                    .filter(\.$userName, .custom("ilike"), "%\(search)%")
                    .sort(\.$userName)
                    .range(range)
                    .all()
            } else {
                return User.query(on: req.db)
                    .filter(\.$userName, .custom("ilike"), "%\(search)%")
                    .all()
            }
        } else {
            if let page = paging.page, let limit = paging.limit {
                let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)
                return User.query(on: req.db)
                    .sort(\.$userName)
                    .range(range)
                    .all()
            } else {
                return User.query(on: req.db).all()
            }
        }
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
                $0.profilePhotoData = user.profilePhotoData
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

    func exists(req: Request) async throws -> Exists {
        let username = req.parameters.get("username") ?? ""
        let count = try await User.query(on: req.db)
            .filter(\.$userName, .custom("ilike"), username)
            .count()
        return Exists(value: count > 0)
    }

    func getUserName(req: Request) async throws -> Username {
        let UID = req.parameters.get("userUID") ?? ""
        let user = try await User.query(on: req.db)
            .filter(\.$userUID == UID)
            .first()
        if let user = user {
            return Username(value: user.userName)
        } else {
            throw Abort(.notFound)
        }
    }
}
