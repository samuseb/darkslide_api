import Foundation
import Vapor

struct FollowUIDs: Content {
    var follower: String?
    var followed: String?
}
