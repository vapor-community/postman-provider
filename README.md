# Vapor Postman Provider

[![Swift](http://img.shields.io/badge/swift-4.2-brightgreen.svg)](https://swift.org)
[![Vapor](http://img.shields.io/badge/vapor-3.0-brightgreen.svg)](https://vapor.codes)
[![CircleCI](https://circleci.com/gh/vapor-community/postman-provider.svg?style=shield)](https://circleci.com/gh/vapor-community/postman-provider)
[![MIT License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

[Postman](https://www.getpostman.com/docs/v6/postman/postman_api/intro_api) is a developer tool for making network requests and testing APIs.

Included in `Postman` is a `PostmanClient` which you can use to get and update your Postman [environments](https://www.getpostman.com/docs/v6/postman/environments_and_globals/manage_environments), especially useful for updating environment variables. 

## Getting Started

In your `Package.swift` file, add the following:

```swift
.package(url: "https://github.com/vapor-community/stripe-provider.git", from: "1.0.0")
```

Register the configuration and the provider.

```swift
let config = PostmanConfi(apiKey: "your-api-key")

services.register(config)

try services.register(PostmanProvider())

app = try Application(services: services)

postmanClient = try app.make(PostmanClient.self)
```

## Using the API

`Postman`'s current functionality revolves around environments. `Postman`'s environment model is `PostmanEnvironment`:

```swift
public struct PostmanEnvironment: Content {
    public let uid: String
    public var name: String
    public var values: [String: String]
}
```

Use the `PostmanClient` to get your environments:

```swift
postmanClient.getEnvironments().map { environments in
    ...
}
```

You can also update your environment:

```swift
let updatedEnvironment = PostmanEnvironment(
    uid: "your-environment-uid", // This doesn't change
    name: "Updated Name",
    values: ["token": updatedToken, "testUserID": newTestUserID]
)

postmanClient.update(updatedEnvironment) // Future<Void>
```

## Error Handling

If requests to the API fail, a `PostmanError` is thrown which includes a `name` and `message` to help you understand what went wrong. 

```swift
postmanClient.update(updatedEnvironment).catch { error in
    if let postmanError = error as? PostmanError {
        postmanError.name
        postmanError.message
    }
}
```
