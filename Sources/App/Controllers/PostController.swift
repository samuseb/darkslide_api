import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: getAll)
        posts.post(use: create)
        posts.put(use: update)
        posts.group(":postID") { post in
            post.delete(use: delete)
        }
        posts.group(":userUID") { post in
            post.get(use: getUserPosts)

            post.group("count") { post2 in
                post2.get(use: getUserPostCount)
            }
        }
        posts.group("search") { post in
            post.get(use: search)
        }
    }

    // GET /posts
    func getAll(req: Request) throws -> EventLoopFuture<[Post]> {
        return Post.query(on: req.db).all()
    }

    // GET /posts/:userUID
    // query params: page, limit for pagination (optional)
    func getUserPosts(req: Request) throws -> EventLoopFuture<[Post]> {
        let userUID = req.parameters.get("userUID") ?? ""
        let paging = try req.query.decode(Paging.self)
        if let page = paging.page, let limit = paging.limit {
            let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)
            return Post.query(on: req.db)
                .filter(\.$userUID == userUID)
                .sort(\.$timeStamp)
                .range(range)
                .all()
        } else {
            return Post.query(on: req.db)
                .filter(\.$userUID == userUID)
                .sort(\.$timeStamp)
                .all()
        }

    }

    // POST /posts
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        let post = try req.content.decode(Post.self, using: decoder)
        return post.save(on: req.db).transform(to: .ok)
    }

    // PUT /posts
    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        let post = try req.content.decode(Post.self, using: decoder)

        return Post.find(post.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.description = post.description
                $0.digital = post.digital
                $0.filmStock = post.filmStock
                $0.camera = post.camera
                $0.lens = post.lens
                $0.shutterSpeed = post.shutterSpeed
                $0.aperture = post.aperture
                $0.iso = post.iso
                $0.imageData = post.imageData
                return $0.update(on: req.db).transform(to: .ok)
            }
    }

    // DELETE /posts/:postID
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Post.find(req.parameters.get("postID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.delete(on: req.db)
            }
            .transform(to: .ok)
    }

    // GET /posts/:userUID/count
    func getUserPostCount(req: Request) async throws -> Count {
        let userUID = req.parameters.get("userUID") ?? ""
        let count = try await Post.query(on: req.db)
            .filter(\.$userUID == userUID)
            .count()
        return Count(value: count)
    }

    // GET /posts/search
    // query params
    func search(req: Request) async throws -> [Post] {
        let paging = try req.query.decode(Paging.self)
        let searchFields = try req.query.decode(PostSearchFields.self)

        var result = Post.query(on: req.db)
            .sort(\.$timeStamp)
        if let page = paging.page, let limit = paging.limit {
            let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)
            result = result.range(range)
        }
        if let camera = searchFields.camera {
            result = result.filter(\.$camera, .custom("ilike"), "%\(camera)%")
        }
        if let lens = searchFields.lens {
            result = result.filter(\.$lens, .custom("ilike"), "%\(lens)%")
        }
        if let description = searchFields.description {
            result = result.filter(\.$description, .custom("ilike"), "%\(description)%")
        }
        if let filmStock = searchFields.filmStock {
            result = result.filter(\.$filmStock, .custom("ilike"), "%\(filmStock)%")
        }
        return try await result.all()
    }
}
