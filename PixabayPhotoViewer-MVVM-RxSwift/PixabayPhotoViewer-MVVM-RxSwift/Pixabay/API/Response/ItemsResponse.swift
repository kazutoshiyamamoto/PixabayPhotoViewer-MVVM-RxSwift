//
//  ItemsResponse.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/20.
//

import Foundation

struct ItemsResponse<Item: Decodable>: Decodable {
    let hits: [Item]
    
    init(hits: [Item]) {
        self.hits = hits
    }
}
