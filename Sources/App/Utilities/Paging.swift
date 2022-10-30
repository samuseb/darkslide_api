import Foundation
import Vapor

struct Paging: Content {
    var page: Int?
    var limit: Int?
}
