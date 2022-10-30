import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "posts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userUID")
    var userUID: String

    @OptionalField(key: "description")
    var description: String?

    @Field(key: "digital")
    var digital: Bool

    @OptionalField(key: "filmStock")
    var filmStock: String?

    @OptionalField(key: "camera")
    var camera: String?

    @OptionalField(key: "lens")
    var lens: String?

    @OptionalField(key: "shutterSpeed")
    var shutterSpeed: String?

    @OptionalField(key: "aperture")
    var aperture: String?

    @OptionalField(key: "iso")
    var iso: Int?

    @Field(key: "imageData")
    var imageData: Data

    @Field(key: "timeStamp")
    var timeStamp: Date

    init() { }

    init(
        id: UUID? = nil,
        userUID: String,
        description: String? = nil,
        digital: Bool,
        filmStock: String? = nil,
        camera: String? = nil,
        lens: String? = nil,
        shutterSpeed: String? = nil,
        aperture: String? = nil,
        iso: Int? = nil,
        imageData: Data,
        timeStamp: Date
    ) {
        self.id = id
        self.userUID = userUID
        self.description = description
        self.digital = digital
        self.filmStock = filmStock
        self.camera = camera
        self.lens = lens
        self.shutterSpeed = shutterSpeed
        self.aperture = aperture
        self.iso = iso
        self.imageData = imageData
        self.timeStamp = timeStamp
    }
}
