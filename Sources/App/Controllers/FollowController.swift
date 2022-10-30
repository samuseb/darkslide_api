import Fluent
import Vapor

struct FollowController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let follows = routes.grouped("follows")
        follows.get(use: getAll)
        follows.post(use: create)
        follows.delete(use: deleteByUIDs)
        follows.group(":followID") { follow in
            follow.delete(use: delete)
        }
        follows.group(":followedUID") { follow in
            follow.group("followers") { follow2 in
                follow2.get(use: getUserFollowerCount)
            }
        }
    }

    // GET /follows
    func getAll(req: Request) throws -> EventLoopFuture<[Follow]> {
        return Follow.query(on: req.db).all()
    }

    // POST /follows
    func create(req: Request) async throws -> HTTPStatus {
        let follow = try req.content.decode(Follow.self)
        let count = try await Follow.query(on: req.db)
            .filter(\.$followerUID == follow.followerUID)
            .filter(\.$followedUID == follow.followedUID)
            .count()

        if count == 0 {
            try await follow.save(on: req.db)
            return HTTPStatus.ok
        } else {
            return HTTPStatus.conflict
        }

    }

    // DELETE /follows/:followID
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Follow.find(req.parameters.get("followID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }
            .transform(to: .ok)
    }

    // DELETE /follows?follower&followed
    func deleteByUIDs(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let followUIDs = try req.query.decode(FollowUIDs.self)
        let follower = followUIDs.follower ?? ""
        let followed = followUIDs.followed ?? ""
        return Follow.query(on: req.db)
            .filter(\.$followerUID == follower)
            .filter(\.$followedUID == followed)
            .delete()
            .transform(to: .ok)
    }

    // GET /dollows/followedUID/count
    func getUserFollowerCount(req: Request) async throws -> Count {
        let userUID = req.parameters.get("followedUID") ?? ""
        let count = try await Follow.query(on: req.db)
            .filter(\.$followedUID == userUID)
            .count()
        return Count(value: count)
    }

}
