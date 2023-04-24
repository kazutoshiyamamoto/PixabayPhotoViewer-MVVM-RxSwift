//
//  SearchImageViewController.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/19.
//

import UIKit
import RxSwift
import RxCocoa

class SearchImageViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var viewModel = SearchImageViewModel(
        searchBarText: searchBar.rx.text.asObservable(),
        searchButtonClicked: searchBar.rx.searchButtonClicked.asObservable(),
        itemSelected: collectionView.rx.itemSelected.asObservable(),
        contentSize: collectionView.rx.observe(CGSize.self, #keyPath(UICollectionView.contentSize)).asObservable(),
        contentOffset: collectionView.rx.contentOffset.asObservable()
    )
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        viewModel.deselectRow
            .bind(to: deselectRow)
            .disposed(by: disposeBag)
        
        viewModel.reloadData
            .bind(to: reloadData)
            .disposed(by: disposeBag)
        
        viewModel.transitionToImageDetail
            .bind(to: transitionToImageDetail)
            .disposed(by: disposeBag)
        
        viewModel.showError
            .bind(to: showError)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 5.0
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width - 20) / 3, height: (UIScreen.main.bounds.size.width - 20) / 3)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = flowLayout
    }
}

extension SearchImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        let image = viewModel.images[indexPath.row]
        cell.configure(image: image)
        
        return cell
    }
}

extension SearchImageViewController {
    private var deselectRow: Binder<IndexPath> {
        return Binder(self) { me, indexPath in
            me.collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    private var reloadData: Binder<Void> {
        return Binder(self) { me, _ in
            me.collectionView.reloadData()
        }
    }
    
    private var transitionToImageDetail: Binder<(Image)> {
        return Binder(self) { me, image in
            let imageDetailVC = UIStoryboard(name: "ImageDetail", bundle: nil).instantiateInitialViewController() as! ImageDetailViewController
            imageDetailVC.image = image
            me.navigationController?.pushViewController(imageDetailVC, animated: true)
        }
    }
    
    private var showError: Binder<(Error)> {
        return Binder(self) { me, error in
            let alert = UIAlertController(title: "error",
                                          message: error.localizedDescription,
                                          preferredStyle:  UIAlertController.Style.alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            me.present(alert, animated: true)
        }
    }
}

extension SearchImageViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}


