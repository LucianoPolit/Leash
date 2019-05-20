# Change Log
All notable changes to this project will be documented in this file.
`Leash` adheres to [Semantic Versioning](http://semver.org/).

#### 3.x Releases
- `3.0.x` Releases - [3.0.0](#300)

#### 2.x Releases
- `2.3.x` Releases - [2.3.0](#230)
- `2.2.x` Releases - [2.2.0](#220)
- `2.1.x` Releases - [2.1.0](#210) | [2.1.1](#211) | [2.1.2](#212) | ~~[2.1.3](#213)~~ | [2.1.4](#214)
- `2.0.x` Releases - [2.0.0](#200) | [2.0.1](#201)

#### 1.x Releases
- `1.1.x` Releases - [1.1.0](#110)
- `1.0.x` Releases - [1.0.0](#100)

---

## [3.0.0](https://github.com/LucianoPolit/Leash/releases/tag/3.0.0)
Released on 2020-02-15.

- Migration to Swift 5.
- Migration to [Alamofire](https://github.com/Alamofire/Alamofire) 5.

## [2.3.0](https://github.com/LucianoPolit/Leash/releases/tag/2.3.0)
Released on 2019-05-20.

- Addition of [Carthage](https://github.com/Carthage/Carthage) support.

## [2.2.0](https://github.com/LucianoPolit/Leash/releases/tag/2.2.0)
Released on 2018-07-25.

- Addition of `Interceptors` module. It contains three customizable `Interceptors`:
    - `LoggerInterceptor`.
    - `BodyValidator`.
    - `CacheInterceptor`.

## [2.1.4](https://github.com/LucianoPolit/Leash/releases/tag/2.1.4)
Released on 2018-07-23.

- Implementation of `Interceptor` protocol to avoid casting on the building.

## ~~[2.1.3](https://github.com/LucianoPolit/Leash/releases/tag/2.1.3)~~
~~Released on 2018-07-20.~~

- ~~Fix of `InterceptorChain` which was being finished despite specifying otherwise.~~

## [2.1.2](https://github.com/LucianoPolit/Leash/releases/tag/2.1.2)
Released on 2018-03-07.

- Fix of an error that was not being propagated on `DataResponseSerializer<Decodable>`.

## [2.1.1](https://github.com/LucianoPolit/Leash/releases/tag/2.1.1)
Released on 2017-12-18.

- Implementation of [SwiftLint](https://github.com/realm/SwiftLint).

## [2.1.0](https://github.com/LucianoPolit/Leash/releases/tag/2.1.0)
Released on 2017-12-03.

- Addition of [RxSwift](https://github.com/ReactiveX/RxSwift) compatibility.
- Modularization of the `Pod Specification` (one `sub-specification` for each module).

## [2.0.1](https://github.com/LucianoPolit/Leash/releases/tag/2.0.1)
Released on 2017-12-01.

- Addition of some typealiases to avoid unnecessary imports.

## [2.0.0](https://github.com/LucianoPolit/Leash/releases/tag/2.0.0)
Released on 2017-11-30.

- Customization of the `DispatchQueue` on which the completion handlers are called.
- Implementation of an `OperationQueue` on the `InterceptorsExecutor`.
- Addition of `SerializationInterceptor`.
- Change of the response handling with the purpose of being serializable.
- Usage of `Data` instead of `T` on the `Interceptors`.
- Improvement of the `Response` to include some utilities.

## [1.1.0](https://github.com/LucianoPolit/Leash/releases/tag/1.1.0)
Released on 2017-11-27.

- Minor improvements to the `Manager` builder.

## [1.0.0](https://github.com/LucianoPolit/Leash/releases/tag/1.0.0)
Released on 2017-11-20.

- Initial release.
