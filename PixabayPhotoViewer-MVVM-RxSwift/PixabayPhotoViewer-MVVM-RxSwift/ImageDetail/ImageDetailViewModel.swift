//
//  ImageDetailPresenter.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/11/06.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit.UIImage

final class ImageDetailViewModel {
    let image: Image
    
    let imageData: Observable<UIImage?>
    
    private let _imageData = BehaviorRelay<UIImage>(value: UIImage())

    private let model: ImageDetailModelProtocol

    private let disposeBag = DisposeBag()
    
    init(image: Image, model: ImageDetailModelProtocol? = nil) {
        self.image = image
        
        imageData = _imageData.map { $0 }

        self.model = model ?? ImageDetailModel(image: image)

        let fetchImageDetail = self.model
            .fetchImage()
            .materialize()

        fetchImageDetail
            .flatMap { event -> Observable<Data> in
                event.element.map(Observable.just) ?? .empty()
            }
            .flatMap { event -> Observable<UIImage> in
                .just(UIImage(data: event)!)
            }
            .bind(to: _imageData)
            .disposed(by: disposeBag)

        fetchImageDetail
            .flatMap { event -> Observable<Error> in
                event.error.map(Observable.just) ?? .empty()
            }.subscribe { error in
                // TODO: Error Handling
            }
            .disposed(by: disposeBag)
    }
}
