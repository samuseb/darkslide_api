import Fluent

struct CreateComments: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("comments")
            .id()
            .field("postID", .string, .required)
            .field("userUID", .string, .required)
            .field("text", .string, .required)
            .field("timeStamp", .datetime, .required)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("comments").delete()
    }
}
