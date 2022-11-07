import Foundation
import Vapor

struct PostSearchFields: Content {
    var camera: String?
    var lens: String?
    var description: String?
    var filmStock: String?
}
