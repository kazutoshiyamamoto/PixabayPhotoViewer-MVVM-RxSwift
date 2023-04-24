//
//  SearchImagePresenter.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/22.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchImageViewModel {
    private let searchImageModel: SearchImageModelProtocol
    
    private let disposeBag = DisposeBag()
    
    var images: [Image] { _images.value.0 }
    
    private let _images = BehaviorRelay<([Image], Pagination)>(value: ([], Pagination(next: nil)))
    
    let deselectRow: Observable<IndexPath>
    
    let reloadData: Observable<Void>
    
    let transitionToImageDetail: Observable<Image>
    
    let showError = PublishRelay<Error>()
    
    let contentOffset: Observable<CGPoint>
    
    let contentSize: Observable<CGSize?>
    
    let _isFetchNextPage = BehaviorRelay<Bool>(value: false)
    
    init(searchBarText: Observable<String?>,
         searchButtonClicked: Observable<Void>,
         itemSelected: Observable<IndexPath>,
         contentSize: Observable<CGSize?>,
         contentOffset: Observable<CGPoint>,
         searchImageModel: SearchImageModelProtocol = SearchImageModel()) {
        
        self.searchImageModel = searchImageModel
        
        self.deselectRow = itemSelected.map { $0 }
        
        self.reloadData = _images.map { _ in }
        
        self.contentSize = contentSize
        
        self.contentOffset = contentOffset
        
        self.transitionToImageDetail = itemSelected
            .withLatestFrom(_images) { ($0, $1) }
            .flatMap { indexPath, images -> Observable<Image> in
                let images = images.0
                guard indexPath.row < images.count else {
                    return .empty()
                }
                return .just(images[indexPath.row])
            }
        
        let searchResponse = searchButtonClicked
            .withLatestFrom(searchBarText)
            .flatMapFirst { [weak self] text -> Observable<Event<([Image], Pagination)>> in
                guard let me = self, let query = text else {
                    return .empty()
                }
                me._images.accept(([], Pagination(next: nil)))
                return me.searchImageModel
                    .fetchImage(query: query, page: 1)
                    .materialize()
            }
            .share()
        
        searchResponse
            .flatMap { event -> Observable<([Image], Pagination)> in
                event.element.map(Observable<([Image], Pagination)>.just) ?? .empty()
            }
            .bind(to: _images)
            .disposed(by: disposeBag)
        
        searchResponse
            .flatMap { event -> Observable<Error> in
                event.error.map(Observable.just) ?? .empty()
            }
            .subscribe(onNext: { [weak self] error in
                self?.showError.accept(error)
            })
            .disposed(by: disposeBag)
        
        let isFetchNextPage = self.contentOffset
            .withLatestFrom(self.contentSize.compactMap { $0?.height }) { ($0, $1) }
            .flatMap { offset, height -> Observable<Bool> in
                let isFetchNextPage = height - 1200 <= offset.y
                return .just(isFetchNextPage)
            }
            .distinctUntilChanged()
        
        let nextPageResponse = isFetchNextPage
            .withLatestFrom(searchBarText) { ($0, $1) }
            .flatMapFirst { [weak self] isFetchNextPage, text -> Observable<Event<([Image], Pagination)>> in
                if !isFetchNextPage { return .empty() }
                guard let me = self, let query = text else {
                    return .empty()
                }
                return me.searchImageModel
                    .fetchImage(query: query, page: me._images.value.1.next ?? 1)
                    .materialize()
            }
            .share()
        
        nextPageResponse
            .flatMap { event -> Observable<([Image], Pagination)> in
                event.element.map(Observable<([Image], Pagination)>.just) ?? .empty()
            }
            .scan(_images.value) { [weak self] (previous, new) -> ([Image], Pagination) in
                guard let me = self else {
                    return ([], Pagination(next: nil))
                }
                let newImages = me._images.value.0 + new.0
                let nextPage = new.1
                return (newImages, nextPage)
            }
            .bind(to: _images)
            .disposed(by: disposeBag)
        
        nextPageResponse
            .flatMap { event -> Observable<Error> in
                event.error.map(Observable.just) ?? .empty()
            }
            .subscribe(onNext: { [weak self] error in
                self?.showError.accept(error)
            })
            .disposed(by: disposeBag)
    }
}
