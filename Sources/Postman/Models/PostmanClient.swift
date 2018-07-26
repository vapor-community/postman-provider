import Vapor

public final class PostmanClient: Service {
    let httpClient: Client
    let apiKey: String
    let apiEndpoint = "https://api.getpostman.com"

    public init(client: Client, apiKey: String) {
        self.httpClient = client
        self.apiKey = apiKey
    }

    private var environmentsEndpoint: String {
        return apiEndpoint + "/environments"
    }

    private var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: MediaType.json.description)
        headers.add(name: "x-api-key", value: apiKey)
        return headers
    }

    private struct ErrorResponse: Codable {
        let error: PostmanError
    }

    public func getEnvironments() throws -> Future<[PostmanEnvironment]> {

        let request = httpClient.get(environmentsEndpoint, headers: headers)

        return request.map { response in
            switch response.http.status {
            case .ok:
                struct EnvironmentsResponse: Codable {
                    let environments: [PostmanEnvironment]
                }

                let environments = try JSONDecoder().decode(EnvironmentsResponse.self, from: response.http.body.data ?? Data())
                return environments.environments

            default:
                let error = try JSONDecoder().decode(ErrorResponse.self, from: response.http.body.data ?? Data())
                throw error.error
            }
        }
    }

    public func update(environment: PostmanEnvironment) throws -> Future<Void> {

        struct EnvironmentParameters: Content {
            let environment: Environment

            struct Environment: Codable {
                let name: String
                let values: [Value]

                struct Value: Codable {
                    let key: String
                    let value: String
                }
            }
        }

        let parameters = EnvironmentParameters(
            environment: .init(
                name: environment.name,
                values: environment.values.map {
                    .init(key: $0.key, value: $0.value)
            }))

        let request = httpClient.put(environmentsEndpoint + "/\(environment.uid)", headers: headers, beforeSend: { request in
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
}
