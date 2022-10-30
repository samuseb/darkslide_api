import Fluent
import Vapor

final class Follow: Model, Content {
    static let schema = "follows"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "followerUID")
    var followerUID: String

    @Field(key: "followedUID")
    var followedUID: String

    init() { }

    init(
        id: UUID? = nil,
        followerUID: String,
        followedUID: String
    ) {
        self.id = id
        self.followerUID = followerUID
        self.followedUID = followedUID
    }
}
