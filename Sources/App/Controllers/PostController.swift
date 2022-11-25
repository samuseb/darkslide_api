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

        posts.group("deleteuser") { post in
            post.group(":userUID") { post2 in
                post2.delete(use: deleteUserPosts)
            }
        }

        posts.group(":userUID") { post in
            post.get(use: getUserPosts)

            post.group("count") { post2 in
                post2.get(use: getUserPostCount)
            }

            post.group("feed") { post2 in
                post2.get(use: getFeed)
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
                .sort(\.$timeStamp, .descending)
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
        if let camera = searchFields.camera?.replacingOccurrences(of: "+", with: " ") {
            result = result.filter(\.$camera, .custom("ilike"), "%\(camera)%")
        }
        if let lens = searchFields.lens?.replacingOccurrences(of: "+", with: " ") {
            result = result.filter(\.$lens, .custom("ilike"), "%\(lens)%")
        }
        if let description = searchFields.description?.replacingOccurrences(of: "+", with: " ") {
            result = result.filter(\.$description, .custom("ilike"), "%\(description)%")
        }
        if let filmStock = searchFields.filmStock?.replacingOccurrences(of: "+", with: " ") {
            result = result.filter(\.$filmStock, .custom("ilike"), "%\(filmStock)%")
        }
        return try await result.all()
    }


    // GET /posts/:useruid/feed
    // query params: page, limit
    func getFeed(req: Request) async throws -> [Post] {
        guard let userUID = req.parameters.get("userUID") else { return [] }
        let paging = try req.query.decode(Paging.self)
        guard let page = paging.page, let limit = paging.limit else { return [] }
        let range = ((page - 1) * limit) ..< (((page - 1) * limit) + limit)

        let follows = try await Follow
            .query(on: req.db)
            .filter(\.$followerUID == userUID)
            .all()
        var followedUIDs = [String]()
        follows.forEach { follow in
            followedUIDs.append(follow.followedUID)
        }

        return try await Post
            .query(on: req.db)
            .filter(\.$userUID ~~ followedUIDs)
            .sort(\.$timeStamp, .descending)
            .range(range)
            .all()
    }

    //DELETE /posts/deleteuser/:userUID
    func deleteUserPosts(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userUID = req.parameters.get("userUID") ?? ""
        return Post
            .query(on: req.db)
            .filter(\.$userUID == userUID)
            .all()
            .flatMap {
                $0.delete(on: req.db)
            }
            .transform(to: .ok)
    }

}
