# Leash

[![Version](https://img.shields.io/cocoapods/v/Leash.svg)](http://cocoapods.org/pods/Leash)
[![Build](https://api.travis-ci.org/LucianoPolit/Leash.svg)](https://travis-ci.org/LucianoPolit/Leash)
[![Coverage](https://codecov.io/gh/LucianoPolit/Leash/graph/badge.svg)](https://codecov.io/gh/LucianoPolit/Leash)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/Leash.svg)](http://cocoadocs.org/docsets/Leash)

## Index

- [Introduction](#introduction)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Setup](#setup)
    - [Encoding](#encoding)
    - [Decoding](#decoding)
    - [Authenticator](#authenticator)
    - [Interceptors](#interceptors)
- [Communication](#communication)
- [Author](#author)
- [License](#license)

## Introduction

Do you use [Alamofire](https://github.com/Alamofire/Alamofire)? Are you used to create some network layer called `APIManager` or `Alamofire+NameOfProject` in every new project? Are you used to spend time deintegrating and taking what you need from previous implementations? Or even coding what you have previously done? What if there is a solution and you should not deal with this anymore?

Now, instead of creating a network layer, you create `Interceptors`, which are responsible for intercepting the requests at different moments of its life cycle (depending on the requirements). Go to [Interceptors](#interceptors) for more information.

Moreover, `Leash` also includes some processes that are common on the network layers, such as [encoding](#encoding), [decoding](#decoding), [authentication](#authenticator) and more. And, just to clarify, it also uses `Alamofire`.

## Example

To run the example project there are two possibilities:

- Run `pod try Leash`.
- Clone the repo and run `pod install` from the Example directory first.

## Requirements

- Xcode 9.0+
- Swift 3.2+

## Installation

Leash is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Leash'
```

## Usage

### Setup

First, we need to configure a `Manager`.  You can see [here](https://github.com/LucianoPolit/Leash/blob/master/Source/Manager.swift) all the options available. Here is an example:

```swift
let manager = Manager.Builder()
    .scheme("http")
    .host("localhost")
    .port(8080)
    .path("api")
    .build()
```

Then, we need a `Client` to create and execute the requests:

```swift
let client = Client(manager: manager)
```

Now, assuming that we have already created an `APIEndpoint` with all the reachable endpoints, we can execute requests. For example:

```swift
client.execute(APIEndpoint.readAllUsers) { (response: [User]) in
    // Do whatever you have to do with the users here.
}
```

Ok, that is good. But, what if we just want to call it like this?

```swift
usersClient.readAll { response in
    // Do whatever you have to do with the users here.
}
```

Much simpler, huh? To keep your project as simple and clean as possible, follow the architecture of the [example project](#example).

### Encoding

Now that you know how to execute the requests you may be asking how to configure the parameters (because `Any` is accepted). There are different options depending if the endpoint is query or body encodable:

- Query types: `QueryEncodable` or `[String : CustomStringConvertible]`.
- Body types: `Encodable` or `[String : Any]`.

Here is an example with all the possibilities:

```swift
enum APIEndpoint {
    case first(QueryEncodable)
    case second([String : CustomStringConvertible])
    case third(Encodable)
    case fourth([String : Any])
}

extension APIEndpoint: Endpoint {

    var path: String {
        return "/it/does/not/matter/"
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
        case .first(let request): return request // This is `QueryEncodable`.
        case .second(let request): return request // This is `[String : CustomStringConvertible]`.
        case .third(let request): return request // This is `Encodable`.
        case .fourth(let request): return request // This is `[String : Any]`.
        }
    }
    
}
```

Three different classes are being used to encode the parameters:

- [URLEncoding](https://github.com/Alamofire/Alamofire#url-encoding): to encode `QueryEncodable` and `[String : CustomStringConvertible]`.
- [JSONEncoding](https://github.com/Alamofire/Alamofire#json-encoding): to encode `[String : Any]`.
- [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder): to encode `Encodable`.

In case you want to encode the parameters in a different way, you have to override the method `Client.urlRequest(for:)`.

### Decoding

When you execute a request you have to specify the type of the response. Also, this type must conform to `Decodable`. After executing the request, in case of a successful response, you will have the response with a value of the specified type. So, a simple example could be:

```swift
client.execute(APIEndpoint.readAllUsers) { (response: [User]) in
    // Here, in case of a successful response, the `response.value` is of the type `[User]`.
}
```

The only available option to decode the body of the response is using the [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder). In case you need to do it in a different way, you should consider doing it through a [SuccessInterceptor](#success).

### Authenticator

Do you need to authenticate your requests? That's something really simple, lets do it!

```swift
class APIAuthenticator {

    var accessToken: String?

}

extension APIAuthenticator: Authenticator {

    static var header: String = "Authorization"

    var authentication: String? {
        guard let accessToken = accessToken else { return nil }
        return "Bearer \(accessToken)"
    }

}
```

Then, you just need to register the authenticator:

```swift
let authenticator = APIAuthenticator()
let manager = Manager.Builder()
    { ... }
    .authenticator(authenticator)
    .build()
```

Now, you have all your requests authenticated. But, are you wondering about token expiration? [Here](#completion) is the solution (the last example)!

### Interceptors

Now, it is the moment of the most powerful tool of this framework. The `Interceptors` gives you the capability to intercept the requests in different moments of its life cycle. There are four different moments to be explicit:

- Execution: called before a request is executed.
- Failure: called when there is a problem executing a request.
- Success: called when there is no problem executing a request.
- Completion: called before the completion handler.

As you may deduce, three types of `Interceptors` are called in every request (`Execution`, `Failure` or `Success`, `Completion`).

The `Manager` can store as many `Interceptors` as you need. And, at the moment of being called, it is done one per time, asynchronously, in a queue order (the same order in which they were added). In case that one of any type is completed requesting to finish the operation, no more `Interceptors` of that type are called.

One of the best advantages is that the `Interceptors` does not depend between them to work. So, any of them is a piece that can be taken out of your project at any moment (without having to deal with compilation issues). Moreover, you can take any of these pieces and reuse them in any other project without having to make changes at all!

Below I will show you how to interact with the different types with some examples. There are a lot more use cases, it is up to you and your requirements!

#### Execution

The purpose of this `Interceptor` is to intercept before a request is executed. Let me show you two examples:

First, the simplest one, we need to log every request that is executed:

```swift
class LoggerInterceptor: ExecutionInterceptor {

    func intercept<T>(chain: InterceptorChain<T>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }

        Logger.shared.logDebug("👉👉👉 \(method) \(url)")
    }
    
}
```

Now, one more complex, but not more difficult to implement:

```swift
class CacheInterceptor: ExecutionInterceptor {

    func intercept<T>(chain: InterceptorChain<T>) {
        // On that case, the cache controller may need to finish the operation or not (depending on the policies).
        // So, we can easily tell the chain wether the operation should be finished or not.
        defer { chain.proceed() }
        guard let cachedResponse: (T, Bool) = try? CacheController().cachedResponse(for: chain.endpoint) else { return }
        chain.complete(with: cachedResponse.0, finish: cachedResponse.1)
    }

}
```

#### Failure

Basically, the purpose of this `Interceptor` is to intercept when `Alamofire` retrieves an error. A simple example could be:

```swift
class ErrorValidator: FailureInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, error: Swift.Error) {
        defer { chain.proceed() }
        guard case SomeError.some = error else { return }
        chain.complete(with: SomeError.another)
    }

}
```

#### Success

Basically, the purpose of this `Interceptor` is to intercept when `Alamofire` retrieves a response. Let me show you two examples:

We know that, sometimes, the `API` could retrieve a custom error with more information:

```swift
class BodyValidator: SuccessInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        defer { chain.proceed() }
        guard let data = response.data else { return }

        if let error = try? chain.client.manager.jsonDecoder.decode(APIError.self, from: data) {
            chain.complete(with: Error.server(error))
        }
    }

}
```

Maybe, there is no custom error, but we still need to validate the status code of the response:

```swift
class ResponseValidator: SuccessInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        defer { chain.proceed() }
        guard let statusCode = response.response?.statusCode else { return }

        let error: Error

        switch statusCode {
            // You should match your errors here.
            case 200...299: return
            case 401, 403: error = .unauthorized
            default: error = .unknown
        }

        chain.complete(with: error)
    }

}
```

#### Completion

The purpose of this `Interceptor` is to intercept before the completion handler is called. Let me show you three examples:

Again, the simplest one, we need to log every response:

```swift
class LoggerInterceptor: CompletionInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }

        switch(response) {
        case .success(_):
            Logger.shared.logDebug("✔✔✔ \(method) \(url)")
        case .failure(let error):
            Logger.shared.logDebug("✖✖✖ \(method) \(url)")
            Logger.shared.logError(error)
        }
    }

}
```

We started before with the `CacheController`, right? Well, now we need to update the cache if needed:

```swift
class CacheInterceptor: CompletionInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        defer { chain.proceed() }
        guard case .success(let value) = response else { return }
        CacheController().updateCacheIfNeeded(for: chain.endpoint, value: value)
    }

}
```

Now, one more complex, we have to update the `authentication` when expired. There are two options here:

- Use the `Adapter` and `Retrier` provided by `Alamofire`.
- Use the [Authenticator](#authenticator) and an `Interceptor`! Let me show you how the `Interceptor` should look like:

```swift
class AuthenticationValidator: CompletionInterceptor {

    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        guard case .failure(let error) = response, case Error.unauthorized = error else {
            chain.proceed()
            return
        }

        RefreshTokenManager.shared.refreshTokenIfNeeded { authenticated in
            guard authenticated else {
                chain.complete(with: Error.unableToAuthenticate)
                return
            }

            do {
                try chain.retry()
            } catch {
                // In almost every case, no error is thrown.
                // But, because we prefer the safest way, we use the do-catch.
                chain.complete(with: Error.unableToRetry)
            }
        }
    }

}
```

## Communication

- If you **need help**, open an issue.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Author

Luciano Polit, lucianopolit@gmail.com

## License

Leash is available under the MIT license. See the LICENSE file for more info.
