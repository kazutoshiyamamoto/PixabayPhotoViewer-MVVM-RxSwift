//
//  SearchImageModel.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/21.
//

import Foundation
import RxSwift

protocol SearchImageModelProtocol {
    func fetchImage(query: String, page: Int) -> Observable<([Image], Pagination)>
}

final class SearchImageModel: SearchImageModelProtocol {
    func fetchImage(query: String, page: Int) -> Observable<([Image], Pagination)> {
        return Observable<([Image], Pagination)>.create { observer in
            let request = SearchImagesRequest(
                query: query,
                page: page,
                perPage: 30
            )
            
            let task = Session().send(request) { result in
                switch result {
                case .success(let response):
                    observer.onNext((response.0.hits, response.1))
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
