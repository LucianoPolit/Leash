<p align="center">
    <img src="./Resources/banner.svg"/>
</p>

<p align="center">
    <a href="https://codecov.io/gh/LucianoPolit/Leash">
        <img src="https://codecov.io/gh/LucianoPolit/Leash/graph/badge.svg" alt="Coverage"/>
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="Swift Package Manager compatible"/>
    </a>
    <a href="http://cocoapods.org/pods/Leash">
        <img src="https://img.shields.io/cocoapods/v/Leash.svg" alt="CocoaPods compatible"/>
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg" alt="Carthage compatible"/>
    </a>
    <a href="https://gitter.im/LeashSwift/community">
        <img src="https://badges.gitter.im/LeashSwift/community.svg" alt="Gitter chat"/>
    </a>
</p>

## Index

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Setup](#setup)
    - [Encoding](#encoding)
    - [Decoding](#decoding)
    - [Authenticator](#authenticator)
    - [Interceptors](#interceptors)
    - [RxSwift](#rxswift)
- [Communication](#communication)
- [Author](#author)
- [License](#license)

## Introduction

Imagine a world where network requests heel to your command, where every call is a well-trained pet on a sturdy `Leash`. Welcome to a place where the repetitive trek through `APIManager` or `Alamofire+ProjectName` becomes a leisurely stroll in the park. With `Leash`, you're not just building a network layer; you're orchestrating a symphony of Interceptors that deftly guide your requests with precision and grace.

Eager for more details? The [Interceptors](#interceptors) section is your gateway to mastery. Beyond command and control, `Leash` brings the finesse of [encoding](#encoding), [decoding](#decoding), and seamless [authentication](#authentication) to your fingertips, all while harmonizing with the familiar tunes of [Alamofire](https://github.com/Alamofire/Alamofire). Embrace the art of network sophistication with `Leash` — where your code's potential knows no bounds.

## Requirements

- Xcode 10.0+
- Swift 5.0+

## Installation

### Swift Package Manager

To integrate `Leash` into your project using [Swift Package Manager](https://swift.org/package-manager), specify it in your `Package.swift`:
```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "YourPackageName",
    dependencies: [
        .package(
            url: "https://github.com/LucianoPolit/Leash.git",
            .upToNextMajor(from: "3.2.0")
        )
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: [
                "Leash",
                "LeashInterceptors",
                "RxLeash"
            ]
        )
    ]
)
```

### CocoaPods

To integrate `Leash` into your project using [CocoaPods](http://cocoapods.org), specify it in your `Podfile`:

```ruby
pod 'Leash', '~> 3.2'
pod 'Leash/Interceptors', '~> 3.2'
pod 'Leash/RxSwift', '~> 3.2'
```

### Carthage

To integrate `Leash` into your project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "LucianoPolit/Leash" ~> 3.2
```

## Usage

### Setup

**Step 1: Configure the Manager**

Start by setting up a `Manager`. You can configure it in detail or use a shortcut method. See [all configurable options](https://github.com/LucianoPolit/Leash/blob/master/Source/Core/Manager.swift). Example configurations:

Detailed setup:

```swift
let manager = Manager.Builder()
    .scheme("http") // Define the scheme.
    .host("localhost") // Specify the host.
    .port(8080) // Set the port.
    .path("api") // Define the base path.
    .build() // Build the manager.
```

Alternatively, for a quick setup:

```swift
let manager = Manager.Builder()
    .url("http://localhost:8080/api") // Set the entire URL in one go.
    .build() // Build the manager.
```

**Step 2: Create a Client**

Next, initialize a `Client` to handle your requests:

```swift
let client = Client(
    manager: manager
)
```

**Step 3: Execute Requests**

With an `Endpoint` set up, you can execute requests. For instance:

```swift
client.execute(
    APIEndpoint.readAllUsers
) { (response: Response<[User]>) in
    // Handle the response here.
}
```

**Simplifying Calls**

Prefer a more concise approach? You can simplify calls like this:

```swift
usersClient.readAll { response in
    // Handle the response here.
}
```

This streamlined method enhances readability and efficiency. For best practices and clean architecture, refer to the [example project](https://github.com/LucianoPolit/Leash/tree/master/Example).

### Encoding

**Understanding Parameter Configuration**

Leash offers versatile ways to configure parameters for different types of requests. You can use various encodings depending on whether your endpoint requires query parameters or body parameters:

- **Query Parameter Types**:
  - `QueryEncodable`
  - `[String: CustomStringConvertible]`

- **Body Parameter Types**:
  - `Encodable`
  - `[String: Any]`

**Example Implementations**

Here's how you can implement each type:

```swift
enum APIEndpoint {
    case first(QueryEncodable)
    case second([String: CustomStringConvertible])
    case third(Encodable)
    case fourth([String: Any])
}

extension APIEndpoint: Endpoint {

    var path: String {
        "/it/does/not/matter/"
    }

    var method: HTTPMethod {
        switch self {
        case .first: return .get
        case .second: return .get
        case .third: return .post
        case .fourth: return .post
        }
    }

    var parameters: Any? {
        switch self {
        case let .first(request): return request // This is `QueryEncodable`.
        case let .second(request): return request // This is `[String: CustomStringConvertible]`.
        case let .third(request): return request // This is `Encodable`.
        case let .fourth(request): return request // This is `[String: Any]`.
        }
    }
    
}
```

**Encoding Classes Used**

`Leash` utilizes different encoding classes:

- [URLEncoding](https://github.com/Alamofire/Alamofire/blob/5.0.0/Source/ParameterEncoding.swift#L59): for `QueryEncodable` and `[String: CustomStringConvertible]`.
- [JSONEncoding](https://github.com/Alamofire/Alamofire/blob/5.0.0/Source/ParameterEncoding.swift#L238): for `[String: Any]`.
- [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder): for `Encodable`.

**Custom Encoding**

To customize parameter encoding, override the `Client.urlRequest(for:)` method.

In case you want to encode the parameters in a different way, you have to override the method `Client.urlRequest(for:)`.

### Decoding

**Specifying the Response Type**

In the process of executing a request with `Leash`, it's essential to define the expected response type, which must adhere to the `Decodable` protocol. This specification ensures that, upon receiving a successful response, Leash will efficiently decode the data into the type you've designated. Here's a straightforward example to illustrate this process:

```swift
client.execute(
    APIEndpoint.readAllUsers
) { (response: Response<[User]>) in
    // On success, `response.value` will be of type `[User]`.
}
```

**Serialization with JSONDecoder**

Leash uses [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder) for response serialization. To customize this process or use a different serializer, implement your own [response serializer](https://github.com/Alamofire/Alamofire/blob/5.0.0/Documentation/AdvancedUsage.md#creating-a-custom-response-serializer), leveraging the [DataResponseSerializerProtocol](https://github.com/Alamofire/Alamofire/blob/5.0.0/Source/ResponseSerialization.swift#L30) from `Alamofire`.

**Example: JSON Response Serializer**

```swift
extension DataRequest {

    @discardableResult
    func responseJSON(
        client: Client,
        endpoint: Endpoint,
        completion: @escaping (Response<Any>) -> Void
    ) -> Self {
        response(
            client: client,
            endpoint: endpoint,
            serializer: JSONResponseSerializer(),
            completion: completion
        )
    }

}
```

**Extending Client for Simplified Request Execution**

```swift
extension Client {

    @discardableResult
    func execute(
        _ endpoint: Endpoint, 
        completion: @escaping (Response<Any>) -> Void
    ) -> DataRequest? {
        do {
            return request(for: endpoint)
                .responseJSON(
                    client: self, 
                    endpoint: endpoint, 
                    completion: completion
                )
        } catch {
            completion(
                .failure(
                    Error.encoding(error)
                )
            )
            return nil
        }
    }

}
```

An example using these extensions might look like this:

```swift
client.execute(
    APIEndpoint.readAllUsers
) { (response: Response<Any>) in
    // On success, `response.value` will be of type `Any`.
}
```

Now, you are empowered to create your own `DataResponseSerializer` and leverage all the capabilities of `Leash`!

### Authenticator

Do you need to authenticate your requests? It's straightforward with `Leash`. Here's how:

```swift
class APIAuthenticator {

    var accessToken: String?

}

extension APIAuthenticator: Authenticator {

    static var header = "Authorization"

    var authentication: String? {
        guard let accessToken = accessToken
        else { return nil }
        return "Bearer \(accessToken)"
    }

}
```

Simply register your authenticator like this:

```swift
let authenticator = APIAuthenticator()
let manager = Manager.Builder()
    { ... } // Include other necessary configurations here.
    .authenticator(authenticator) // Register the authenticator.
    .build() // Build the manager.
```

And voilà! Your requests are now authenticated. Concerned about token expiration? Check out the solution [here](#completion)!

### Interceptors

**Unlocking the Framework's Core Power**

`Interceptors` are `Leash`'s powerhouse, offering the ability to act at various stages of a request's lifecycle. They are categorized into five types for precise intervention:

- **Execution**: Called before the execution of a request.
- **Failure**: Called when an issue arises during request execution.
- **Success**: Called following a successful request.
- **Completion**: Called just before the completion handler is called.
- **Serialization**: Called post-serialization of the response.

**Lifecycle Integration**

Every request passes through at least three interceptor types: `Execution`, `Failure` or `Success`, and `Completion`. The `Serialization` type is utilized based on whether you're serializing a response or not.

**Modularity and Asynchronous Execution**

The `Manager` can hold an array of `Interceptors`, executed asynchronously and in the order they were added. This queuing ensures a sequential and organized processing flow. If an interceptor requests to conclude an operation, subsequent interceptors of the same type won't be called, providing efficient error handling and flow control.

**Independent yet Cohesive**

Each interceptor operates independently, ensuring no interdependencies that could complicate your project's structure. This modular design allows for easy removal or addition of interceptors without impacting other components. Furthermore, their reusability across different projects adds to their versatility.

**Integrating Interceptors**

To add an interceptor to your `Manager`, follow this pattern:

```swift
let manager = Manager.Builder()
    { ... } // Include other necessary configurations here.
    .add(
        interceptor: CustomInterceptor() // Insert your custom interceptor.
    )
    .build()
```

#### Execution

**Enhancing Request Readiness**

The Execution Interceptor allows for pre-request adjustments and monitoring. Two key implementations demonstrate its versatility:

1. **LoggerInterceptor**: Logs details of every request for effective tracking and debugging.

```swift
class LoggerInterceptor: ExecutionInterceptor {

    func intercept(
        chain: InterceptorChain<Data>
    ) {
        defer { chain.proceed() }

        guard let request = try? chain.request.convertible.asURLRequest(),
              let method = request.httpMethod,
              let url = request.url?.absoluteString
        else { return }

        Logger.shared.logDebug("👉👉👉 \(method) \(url)")
    }
    
}
```

2. **CacheInterceptor**: Determines whether to use cached responses or proceed with a network request.

```swift
class CacheInterceptor: ExecutionInterceptor {

    let controller = CacheController()

    func intercept(
        chain: InterceptorChain<Data>
    ) {
        // In this scenario, the cache controller decides whether to complete
        // the operation based on predefined policies.
        // This allows us to instruct the chain to either finish or continue the operation.
        defer { chain.proceed() }

        guard let cachedResponse = try? controller.cachedResponse(
            for: chain.endpoint
        )
        else { return }

        chain.complete(
            with: cachedResponse.data, 
            finish: cachedResponse.finish
        )
    }

}
```

#### Failure

**Handling Request Errors Gracefully**

The Failure Interceptor steps in when `Alamofire` encounters an error. Consider this example:

**ErrorValidator**: A simple but essential interceptor that checks for specific error conditions and modifies or handles them accordingly.

```swift
class ErrorValidator: FailureInterceptor {

    func intercept(
        chain: InterceptorChain<Data>,
        error: Swift.Error
    ) {
        defer { chain.proceed() }

        guard case Error.some = error
        else { return }

        chain.complete(
            with: Error.another
        )
    }

}
```

#### Success

**Optimizing Response Management**

The Success Interceptor is pivotal when Alamofire successfully retrieves a response, offering a chance to perform additional validations or processing. Here are two illustrative examples:

1. **BodyValidator**: This interceptor decodes the response data to check for API-specific errors. If found, it handles them appropriately.

```swift
class BodyValidator: SuccessInterceptor {

    func intercept(
        chain: InterceptorChain<Data>, 
        response: HTTPURLResponse, 
        data: Data
    ) {
        defer { chain.proceed() }

        guard let error = try? chain.client.manager.jsonDecoder.decode(
            APIError.self,
            from: data
        )
        else { return }

        chain.complete(
            with: Error.server(error)
        )
    }

}
```

2. **ResponseValidator**: This interceptor focuses on validating the HTTP status code of the response. It categorizes the response based on the status code, assigning appropriate errors for specific ranges or conditions.

```swift
class ResponseValidator: SuccessInterceptor {

    func intercept(
        chain: InterceptorChain<Data>, 
        response: HTTPURLResponse, 
        data: Data
    ) {
        defer { chain.proceed() }

        let error: Error

        switch response.statusCode {
            case 200 ... 299: return
            case 401, 403: error = .unauthorized
            default: error = .unknown
        }

        chain.complete(
            with: error
        )
    }

}
```

#### Completion

**Refining the Final Stages of a Request**

The Completion Interceptor acts just before the completion handler provided. Here are two examples:

1. **LoggerInterceptor**: Logs the outcome of every response, distinguishing between success and failure.

```swift
class LoggerInterceptor: CompletionInterceptor {

    func intercept(
        chain: InterceptorChain<Data>, 
        response: Response<Data>
    ) {
        defer { chain.proceed() }

        guard let request = try? chain.request.convertible.asURLRequest(),
              let method = request.httpMethod,
              let url = request.url?.absoluteString
        else { return }

        switch response {
        case .success:
            Logger.shared.logDebug("✔✔✔ \(method) \(url)")
        case .failure(let error):
            Logger.shared.logDebug("✖✖✖ \(method) \(url)")
            Logger.shared.logError(error)
        }
    }

}
```

2. **AuthenticationValidator**: This more complex interceptor steps in when authentication issues arise. It refreshes tokens as needed, ensuring continuous authenticated access.

```swift
class AuthenticationValidator: CompletionInterceptor {

    func intercept(
        chain: InterceptorChain<Data>, 
        response: Response<Data>
    ) {
        guard let error = response.error,
              case Error.unauthorized = error,
              let authenticator = chain.client.manager.authenticator as? APIAuthenticator
        else {
            chain.proceed()
            return
        }

        RefreshTokenManager.shared.refreshTokenIfNeeded { authenticated, accessToken in
            guard authenticated
            else {
                chain.complete(
                    with: Error.unableToAuthenticate
                )
                return
            }
            
            authenticator.accessToken = accessToken

            do {
                try chain.retry()
            } catch {
                // Typically, retrying does not throw an error.
                // However, for maximum safety and to handle unexpected scenarios,
                // we wrap it in a do-catch block.
                chain.complete(
                    with: Error.unableToRetry
                )
            }
        }
    }

}
```

Note: You can also use the [Adapter](https://github.com/Alamofire/Alamofire/blob/5.0.0/Documentation/AdvancedUsage.md#requestadapter) and [Retrier](https://github.com/Alamofire/Alamofire/blob/5.0.0/Documentation/AdvancedUsage.md#requestretrier) provided by `Alamofire`.







#### Serialization

The Serialization Interceptor is the final and optional phase in the request lifecycle, dependent on whether you are [serializing](#decoding) your response or just handling the `Data`.

For example, in continuation with the `CacheController`, here's how you can update the cache with a successfully serialized response:

```swift
class CacheInterceptor: SerializationInterceptor {

    let controller = CacheController()

    func intercept<T: DataResponseSerializerProtocol>(
        chain: InterceptorChain<T.SerializedObject>,
        response: Response<Data>,
        result: Result<T.SerializedObject, Swift.Error>,
        serializer: T
    ) {
        defer { chain.proceed() }

        guard let value = response.value, 
              (try? result.get()) != nil
        else { return }

        controller.updateCacheIfNeeded(
            for: chain.endpoint, 
            value: value
        )
    }

}
```

### RxSwift

For those who are fans of [RxSwift](https://github.com/ReactiveX/RxSwift), Leash has got you covered with a dedicated extension. Here's how you can streamline your network calls using RxSwift:

```swift
client.rx.execute(
    APIEndpoint.readAllUsers, 
    type: [User].self
).subscribe { event in
    // Handle the response event here.
}
```

Seeking an even more concise approach? You can simplify it further:

```swift
usersClient.rx.readAll().subscribe { event in
    // Handle the response event here.
}
```

This approach aligns perfectly with the ethos of keeping your project simple and clean. For an in-depth understanding and best practices, explore the structure outlined in the [example project](https://github.com/LucianoPolit/Leash/tree/master/Example).

## Communication

- If you **need help**, open an issue.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Author

Luciano Polit, lucianopolit@gmail.com

## License

`Leash` is available under the MIT license. See the [LICENSE](https://github.com/LucianoPolit/Leash/blob/master/LICENSE) file for more info.
