import Fluent
import Vapor

struct CommentController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let comments = routes.grouped("comments")
        comments.get(use: getAll)
        comments.post(use: create)
        comments.put(use: update)
        comments.group(":commentID") { comment in
            comment.delete(use: delete)
        }

        comments.group(":postID") { comment in
            comment.get(use: getPostComments)
        }
    }

    // GET /comments
    func getAll(req: Request) throws -> EventLoopFuture<[Comment]> {
        Comment.query(on: req.db).all()
    }

    // GET /comments/:postID
    // query params: page, limit
    func getPostComments(req: Request) throws -> EventLoopFuture<[Comment]> {
        let paging = try req.query.decode(Paging.self)
        if let page = paging.page, let limit = paging.limit {
            let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)
            return Comment.query(on: req.db)
                .filter(\.$postID == req.parameters.get("postID") ?? "")
                .sort(\.$timeStamp)
                .range(range)
                .all()
        } else {
            return Comment.query(on: req.db)
                .filter(\.$postID == req.parameters.get("postID") ?? "")
                .sort(\.$timeStamp)
                .all()
        }

    }

    // POST /comments
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        let comment = try req.content.decode(Comment.self, using: decoder)
        return comment.save(on: req.db).transform(to: .ok)
    }

    // PUT /comments
    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        let comment = try req.content.decode(Comment.self, using: decoder)

        return Comment.find(comment.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.text = comment.text
                return $0.update(on: req.db).transform(to: .ok)
            }
    }

    // DELETE /comments/:commentID
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Comment.find(req.parameters.get("commentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
