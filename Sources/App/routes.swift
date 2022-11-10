import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "5mb"

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: PostController())
    try app.register(collection: UserController())
    try app.register(collection: FollowController())
    try app.register(collection: CommentController())
}
