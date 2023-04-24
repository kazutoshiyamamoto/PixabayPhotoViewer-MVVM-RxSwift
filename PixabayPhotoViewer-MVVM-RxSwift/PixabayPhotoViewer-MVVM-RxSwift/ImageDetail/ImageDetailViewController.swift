//
//  ImageDetailViewController.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/11/06.
//

import UIKit
import RxSwift
import RxCocoa

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var downloads: UILabel!
    
    var image: Image!
    
    private lazy var viewModel = ImageDetailViewModel(image: image)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        viewModel.imageData
            .bind(to: imageDetail.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        userName.text = image.user
        tags.text = image.tags
        views.text = String(image.views)
        downloads.text = String(image.downloads)
    }
}
