# Vapor Postman Provider

[![Swift](http://img.shields.io/badge/swift-4.2-brightgreen.svg)](https://swift.org)
[![Vapor](http://img.shields.io/badge/vapor-3.0-brightgreen.svg)](https://vapor.codes)
[![CircleCI](https://circleci.com/gh/vapor-community/postman-provider.svg?style=shield)](https://circleci.com/gh/vapor-community/postman-provider)
[![MIT License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

[Postman](https://www.getpostman.com/docs/v6/postman/postman_api/intro_api) is a developer tool for making network requests and testing APIs.

Included in `Postman` is a `PostmanClient` which you can use to get and update your Postman [environment](https://www.getpostman.com/docs/v6/postman/environments_and_globals/manage_environments), especially useful for updating environment variables. 

## Getting Started

In your `Package.swift` file, add the following:

```swift
.package(url: "https://github.com/vapor-community/postman-provider.git", from: "1.0.0")
```

Register the configuration and the provider.

```swift
let config = PostmanConfig(apiKey: "your-api-key", environmentUID: "your-environment-uid")

services.register(config)

try services.register(PostmanProvider())

app = try Application(services: services)

postmanClient = try app.make(PostmanClient.self)
```
*Note: `environmentUID` is your environment's `"uid"` and **not** your environment's `"id"`.*

## Using the API

`Postman`'s current functionality revolves around environments. `Postman`'s environment model is `PostmanEnvironment`:

```swift
public struct PostmanEnvironment: Content {
    public var name: String
    public var values: [String: String]
}
```
There is a distinction between initial and current environment variable values. Initial environment varaible values are synced across workspaces and teams if you share the environment. Current environment variable values are the values that are actually used when making requests. Until they are changed, they assume the initial values. Read more about environment variables [here](https://www.getpostman.com/docs/v6/postman/environments_and_globals/variables). 

### Getting Your Environment

Use the `PostmanClient` to get your environment:

```swift
postmanClient.getEnvironment().map { environment in
    environment.name
    environment.values
}
```

*Note: The values are the *initial* environment variables, not the current.*

### Updating Your Environment

The client provides methods for updating both the initial environment variables (`updateInitialEnvironment(...)`) and the current environment variables by using a workaround, discussed later, (`updateCurrentEnvironment(...)`). Environments can be updated using two different strategies:
 1. By replacing the environment entirely (`update*Environment(byReplacingWith:`)
 2. By merging values from a new environment into the existing environment using a merge strategy when duplicate keys are encountered (`update*Environment(byMergingWith:strategy:)`).

Updating your environment's initial environment variables...

```swift
let updatedEnvironment = PostmanEnvironment(
    name: "Updated Name",
    values: ["token": updatedToken, "testUserID": newTestUserID]
)

// ... by replacing the entire environment
postmanClient.updateInitialEnvironment(byReplacingWith: updatedEnvironment)

// ... by merging a new environment into the existing environment
postmanClient.updateInitialEnvironment(byMergingWith: updatedEnvironment, strategy: .useNewValueForDuplicateKeys)
```

The same calls existing for updating your environment's current environment variables.

It is important to note that when you update your environment by replacing, the entire environment will be replaced. So if an existing environment variable is not included in `values` it will be deleted.

There are three different merge strategies to determine which value should be used when a duplicate key is found between the two environments being merged.

1. `keepCurrentValueForDuplicateKeys`: Keeps the current value.
2. `useNewValueForDuplicateKeys`: Uses the new value.
3. `closure((String, String) -> String)`: Use a closure that accepts two strings, the current and new values respectively, and returns the string to use as the value.

#### A note on updating the current environment:

The Postman API only allows you to update the initial environment variable values. So if you update and existing environment using the API, the requests you make will have the old "current" value. However, because current values assume initial values when they are first created, if you delete all of the environment variables and then recreate them, initial and current values will be in sync with one another. So the `updateCurrentEnvironment` variants do exactly that, they create a copy of the environment and its variables, delete the variables, and then recreate them. Kind of hacky, but it works! That said, because environments are being wiped and recreated, make sure you have a backup of your environment just in case anything goes wrong.

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
