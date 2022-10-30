import Fluent

struct CreatePosts: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("posts")
            .id()
            .field("userUID", .string, .required)
            .field("description", .string)
            .field("digital", .bool)
            .field("filmStock", .string)
            .field("camera", .string)
            .field("lens", .string)
            .field("shutterSpeed", .string)
            .field("aperture", .string)
            .field("iso", .int)
            .field("imageData", .data, .required)
            .field("timeStamp", .datetime, .required)
            .create()
    }

    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        return database.schema("posts").delete()
    }
}
