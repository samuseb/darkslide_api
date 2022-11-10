import Fluent

struct CreateFollows: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("follows")
            .id()
            .field("followerUID", .string, .required)
            .field("followedUID", .string, .required)
            .field("timeStamp", .datetime, .required)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("follows").delete()
    }
}
