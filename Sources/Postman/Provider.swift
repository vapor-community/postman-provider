import Vapor

public struct PostmanConfig: Service {
    let apiKey: String
    let environmentUID: String

    public init(apiKey: String, environmentUID: String) {
        self.apiKey = apiKey
        self.environmentUID = environmentUID
    }
}

public final class PostmanProvider: Provider {
    public static let repositoryName = "postman-provider"

    public init() {}

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

    public func register(_ services: inout Services) throws {
        services.register { container -> PostmanClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(PostmanConfig.self)
            return PostmanClient(
                client: httpClient,
                apiKey: config.apiKey,
                environmentUID: config.environmentUID)
        }
    }
}
