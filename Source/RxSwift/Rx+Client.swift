//
//  Rx+Client.swift
//  Alamofire
//
//  Created by Luciano Polit on 12/1/17.
//

import Foundation
import RxSwift

// MARK: - Reactive

extension Client: ReactiveCompatible { }

extension Reactive where Base: Client {
    
    public func execute<T: Decodable>(_ endpoint: Endpoint, queue: DispatchQueue? = nil) -> Single<ReactiveResponse<T>> {
        return base.execute(endpoint, queue: queue)
    }
    
    public func execute<T: Decodable>(_ endpoint: Endpoint, queue: DispatchQueue? = nil) -> Observable<T> {
        return base.execute(endpoint, queue: queue)
            .asObservable()
            .withoutExtra()
    }
    
}

// MARK: - Utils

private extension Client {
    
    func execute<T: Decodable>(_ endpoint: Endpoint, queue: DispatchQueue? = nil) -> Single<ReactiveResponse<T>> {
        return Single.create { single in
            let disposable: Disposable?
            
            do {
                let request = try self.request(for: endpoint)
                disposable = request.rx
                    .responseDecodable(queue: queue, client: self, endpoint: endpoint)
                    .subscribe { event in
                        single(event)
                    }
            } catch {
                disposable = nil
                single(.error(error))
            }
            
            return Disposables.create { disposable?.dispose() }
        }
    }
    
}
