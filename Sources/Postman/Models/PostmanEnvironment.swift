import Vapor

/// A Postman environment.
public struct PostmanEnvironment: Content {

    /// The name of the environment.
    public var name: String

    /// The environment variables represented as a dictionary.
    public var values: [String: String]

    private enum CodingKeys: CodingKey {
        case name
        case values
    }

    private struct Value: Codable {
        let key: String
        let value: String
    }

    public init(name: String, values: [String: String]) {
        self.name = name
        self.values = values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        let values: [Value] = try container.decode([Value].self, forKey: .values)
        self.values = Dictionary(uniqueKeysWithValues: values.map { ($0.key, $0.value) })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let values = self.values.map(Value.init)
        try container.encode(values, forKey: .values)
    }

    /// The strategy to use to determine which value to keep when a duplicate key is encountered.
    public enum MergeStrategy {
        /// Keeps the current value.
        case keepCurrentValueForDuplicateKeys
        /// Uses the new value.
        case useNewValueForDuplicateKeys
        /// Use a closure that accepts two strings, the current and new values respectively,
        /// and returns the string to use as the value.
        case closure((String, String) -> String)

        var closure: (String, String) -> String {
            switch self {
            case .keepCurrentValueForDuplicateKeys:
                return { current, _ in current }
            case .useNewValueForDuplicateKeys:
                return { _, new in new }
            case .closure(let closure):
                return closure
            }
        }
    }

    /// Merge values into `self` from another environment.
    ///
    /// - parameter anotherEnvironment: The environment which will be merged into `self`.
    /// - parameter strategy: See `PostmanEnvironment.MergeStrategy`.
    ///
    public mutating func mergeValues(from anotherEnvironment: PostmanEnvironment, strategy: MergeStrategy) {
        values.merge(anotherEnvironment.values, uniquingKeysWith: strategy.closure)
    }

    /// Returns a new environment by merging from another environment into `self`.
    ///
    /// - parameter anotherEnvironment: The environment which will be merged into `self`.
    /// - parameter strategy: See `PostmanEnvironment.MergeStrategy`.
    /// - returns: A new environment which is the result of the merge.
    ///
    public func mergingValues(from anotherEnvironment: PostmanEnvironment, strategy: MergeStrategy) -> PostmanEnvironment {
        var copy = self
        copy.mergeValues(from: anotherEnvironment, strategy: strategy)
        return copy
    }
}
