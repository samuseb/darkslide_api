import Fluent
import Vapor

final class Comment: Model, Content {
    static let schema = "comments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "text")
    var text: String

    @Field(key: "postID")
    var postID: String

    @Field(key: "userUID")
    var userUID: String

    @Field(key: "timeStamp")
    var timeStamp: Date

    init() { }

    init(
        id: UUID? = nil,
        postID: String,
        userUID: String,
        timeStamp: Date
    ) {
        self.id = id
        self.postID = postID
        self.userUID = userUID
        self.timeStamp = timeStamp
    }
}
