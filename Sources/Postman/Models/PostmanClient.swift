import Vapor

/// A client which can make calls to the Postman API.
public final class PostmanClient: Service {
    let httpClient: Client
    let apiKey: String
    let environmentUID: String
    let apiEndpoint = "https://api.getpostman.com"

    public init(client: Client, apiKey: String, environmentUID: String) {
        self.httpClient = client
        self.apiKey = apiKey
        self.environmentUID = environmentUID
    }

    private var environmentEndpoint: String {
        return apiEndpoint + "/environments/\(environmentUID)"
    }

    private var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: MediaType.json.description)
        headers.add(name: "x-api-key", value: apiKey)
        return headers
    }

    private struct EnvironmentContainer: Content {
        let environment: PostmanEnvironment
    }

    private struct ErrorResponse: Codable {
        let error: PostmanError
    }

    /// Gets the environment.
    ///
    /// - note: The values are the *initial* environment variables, not the current.
    ///
    /// - returns: A future `PostmanEnvironment`.
    ///
    public func getEnvironment() -> Future<PostmanEnvironment> {

        let request = httpClient.get(environmentEndpoint, headers: headers)

        return request.map { response in
            switch response.http.status {
            case .ok:
                let container = try JSONDecoder().decode(EnvironmentContainer.self, from: response.http.body.data ?? Data())
                return container.environment

            default:
                let error = try JSONDecoder().decode(ErrorResponse.self, from: response.http.body.data ?? Data())
                throw error.error
            }
        }
    }

    /// Updates your environment by replacing the *initial* environment variables with those from the new environment.
    ///
    /// - parameter newEnvironment: The environment whose `name` and `values` will be used to update the initial environment variables.
    ///
    public func updateInitialEnvironment(byReplacingWith newEnvironment: PostmanEnvironment) -> Future<Void> {

        let parameters = EnvironmentContainer(environment: newEnvironment)
        let request = httpClient.put(environmentEndpoint, headers: headers, beforeSend: { request in
            try request.content.encode(parameters)
        })

        return request.map { response in
            switch response.http.status {
            case .ok:
                return
            default:
                let error = try JSONDecoder().decode(ErrorResponse.self, from: response.http.body.data ?? Data())
                throw error.error
            }
            }.transform(to: ())
    }

    /// Updates your environment by getting your current environment, merging it with the other environment using the provided strategy,
    /// and then replacing the *initial* environment variables with those from the merged environment.
    ///
    /// - parameter otherEnvironment: The environment which will be merged into the current environment.
    /// - parameter strategy: See `PostmanEnvironment.MergeStrategy`.
    ///
    public func updateInitialEnvironment(byMergingWith otherEnvironment: PostmanEnvironment, strategy: PostmanEnvironment.MergeStrategy) -> Future<Void> {
        return getEnvironment().flatMap { currentEnvironment in
            let mergedEnvironment = currentEnvironment.mergingValues(from: otherEnvironment, strategy: strategy)
            return self.updateInitialEnvironment(byReplacingWith: mergedEnvironment)
        }
    }

    /// Updates your environment by replacing the *current* environment variables with those from the new environment.
    ///
    /// - note: Your current environment variables are updated by first deleting the entire environment and then replacing it.
    ///         This is a workaround in the way that Postman's API works.
    ///
    /// - parameter newEnvironment: The environment whose `name` and `values` will be used to update the current environment variables.
    ///
    public func updateCurrentEnvironment(byReplacingWith newEnvironment: PostmanEnvironment) -> Future<Void> {
        var emptyEnvironment = newEnvironment
        emptyEnvironment.values = [:]
        return updateInitialEnvironment(byReplacingWith: emptyEnvironment).flatMap { _ in
            self.updateInitialEnvironment(byReplacingWith: newEnvironment)
        }
    }

    /// Updates your environment by getting your current environment, merging it with the other environment using the provided strategy,
    /// and then replacing the *current* environment variables with those from the merged environment.
    ///
    /// - note: Your current environment variables are updated by first deleting the entire environment and then replacing it.
    ///         This is a workaround in the way that Postman's API works.
    ///
    /// - parameter otherEnvironment: The environment which will be merged into the current environment.
    /// - parameter strategy: See `PostmanEnvironment.MergeStrategy`.
    ///
    public func updateCurrentEnvironment(byMergingWith otherEnvironment: PostmanEnvironment, strategy: PostmanEnvironment.MergeStrategy) -> Future<Void> {
        return getEnvironment().flatMap { currentEnvironment in
            let mergedEnvironment = currentEnvironment.mergingValues(from: otherEnvironment, strategy: strategy)
            return self.updateCurrentEnvironment(byReplacingWith: mergedEnvironment)
        }
    }
}

// TODO: Deprecate this
//extension PostmanClient {
//
//    public func update(_ environment: PostmanEnvironment) -> Future<Void> {
//
//    }
//}
