import Vapor

public struct PostmanEnvironment: Content {
    public let uid: String
    public var name: String
    public var values: [String: String]

    public init(uid: String, name: String, values: [String: String]) {
        self.uid = uid
        self.name = name
        self.values = values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        name = try container.decode(String.self, forKey: .name)
        values = [:]
    }
}
