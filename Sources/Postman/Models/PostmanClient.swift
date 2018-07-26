import Vapor

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

    public func update(_ environment: PostmanEnvironment) -> Future<Void> {

        let parameters = EnvironmentContainer(environment: environment)

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
}
