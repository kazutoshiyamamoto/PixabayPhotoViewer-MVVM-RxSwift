//
//  Request.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/20.
//

import Foundation

protocol Request {
    associatedtype Response: Decodable
    
    var baseURL: URL { get }
    var method: HttpMethod { get }
    var headerFields: [String: String] { get }
    var queryParameters: [String: String]? { get }
    var apiKey: String { get }
}

extension Request {
    var baseURL: URL {
        return URL(string: "https://pixabay.com/api/")!
    }
    
    var headerFields: [String: String] {
        return ["Accept": "application/json"]
    }
    
    var queryParameters: [String: String]? {
        return nil
    }
    
    var apiKey: String {
        return ""
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}
