import Fluent

struct CreateUsers: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("userUID", .string, .required)
            .field("userName", .string, .required)
            .field("coverPhotoData", .data)
            .field("bioDescription", .string)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("users").delete()
    }

}
