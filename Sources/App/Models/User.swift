import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "userUID")
    var userUID: String

    @Field(key: "userName")
    var userName: String

    @OptionalField(key: "coverPhotoData")
    var coverPhotoData: Data?

    @OptionalField(key: "profilePhotoData")
    var profilePhotoData: Data?

    @OptionalField(key: "bioDescription")
    var bioDescription: String?

    init() { }

    init(
        id: UUID? = nil,
        userUID: String,
        userName: String,
        coverPhotoData: Data? = nil,
        profilePhotoData: Data? = nil,
        bioDescription: String? = nil
    ) {
        self.id = id
        self.userUID = userUID
        self.userName = userName
        self.coverPhotoData = coverPhotoData
        self.profilePhotoData = profilePhotoData
        self.bioDescription = bioDescription
    }
}
