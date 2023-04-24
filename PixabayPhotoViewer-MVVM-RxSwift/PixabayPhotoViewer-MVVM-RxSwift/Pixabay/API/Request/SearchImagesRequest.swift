//
//  SearchImagesRequest.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/20.
//

import Foundation

struct SearchImagesRequest: Request {
    typealias Response = ItemsResponse<Image>
    
    let method: HttpMethod = .get
    
    var queryParameters: [String : String]? {
        var params: [String: String] = [
            "key": apiKey,
            "q": query
        ]
        if let page = page {
            params["page"] = "\(page)"
        }
        if let perPage = perPage {
            params["per_page"] = "\(perPage)"
        }
        return params
    }
    
    let query: String
    let page: Int?
    let perPage: Int?
    
    init(query: String, page: Int?, perPage: Int?) {
        self.query = query
        self.page = page
        self.perPage = perPage
    }
}
