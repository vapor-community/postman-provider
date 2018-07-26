import Vapor

public struct PostmanEnvironment: Content {
    public var name: String
    public var values: [String: String]

    public init(name: String, values: [String: String]) {
        self.name = name
        self.values = values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let values: [Value] = try container.decode([Value].self, forKey: .values)
        self.values = Dictionary(pairs: values.map { ($0.key, $0.value) })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let values = self.values.map(Value.init)
        try container.encode(values, forKey: .values)
    }

    private enum CodingKeys: CodingKey {
        case name
        case values
    }
}

private struct Value: Codable {
    let key: String
    let value: String
}

private extension Dictionary {
    init(pairs: [(Key, Value)]) {
        self = [:]
        pairs.forEach { self[$0.0] = $0.1 }
    }
}
