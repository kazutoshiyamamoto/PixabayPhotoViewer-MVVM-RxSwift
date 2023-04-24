//
//  ImageDetailModel.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/11/06.
//

import Foundation
import RxSwift

protocol ImageDetailModelProtocol {
    func fetchImage() -> Observable<Data>
}

final class ImageDetailModel: ImageDetailModelProtocol {
    private let image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    func fetchImage() -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let me = self else { return Disposables.create() }
            
            let task = URLSession.shared.dataTask(with: me.image.webformatURL) { data, response, error in
                if let data = data {
                    observer.onNext(data)
                    observer.onCompleted()
                } else {
                    observer.onError(error!)
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
