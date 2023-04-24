//
//  Image.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/20.
//

import Foundation

struct Image: Codable {
    var id: Int
    var tags: String
    var user: String
    var views: Int
    var downloads: Int
    var previewURL: URL
    var webformatURL: URL
    
    init(id: Int,
         tags: String,
         user: String,
         views: Int,
         downloads: Int,
         previewURL: URL,
         webformatURL: URL) {
        self.id = id
        self.tags = tags
        self.user = user
        self.views = views
        self.downloads = downloads
        self.previewURL = previewURL
        self.webformatURL = webformatURL
    }
}
