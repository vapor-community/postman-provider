import Vapor

public struct PostmanError: Content, Error {
    public let name: String
    public let message: String
}

extension PostmanError: Debuggable {
    public var identifier: String {
        return "PostmanError." + name
    }

    public var reason: String {
        return message
    }
}
