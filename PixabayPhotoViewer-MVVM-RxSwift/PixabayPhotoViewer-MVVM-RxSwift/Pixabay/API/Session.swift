//
//  Session.swift
//  PixabayPhotoViewer-MVVM-RxSwift
//
//  Created by home on 2021/10/20.
//

import Foundation

enum SessionError: Error {
    case noData(HTTPURLResponse)
    case noResponse
    case unacceptableStatusCode(Int, String)
    case failedToCreateComponents(URL)
    case failedToCreateURL(URLComponents)
}

final class Session {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    @discardableResult
    func send<T: Request>(_ request: T, completion: @escaping (Result<(T.Response, Pagination), Error>) -> ()) -> URLSessionTask? {
        let url = request.baseURL
        
        guard var componets = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(SessionError.failedToCreateComponents(url)))
            return nil
        }
        componets.queryItems = request.queryParameters?.compactMap(URLQueryItem.init)
        
        guard var urlRequest = componets.url.map({ URLRequest(url: $0) }) else {
            completion(.failure(SessionError.failedToCreateURL(componets)))
            return nil
        }
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headerFields
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(SessionError.noResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(SessionError.noData(response)))
                return
            }
            
            guard  200..<300 ~= response.statusCode else {
                completion(.failure(SessionError.unacceptableStatusCode(response.statusCode, response.debugDescription)))
                return
            }
            
            let pagination: Pagination
            if let page = request.queryParameters?["page"] {
                let next = Int(page)! + 1
                pagination = Pagination(next: next)
            } else {
                pagination = Pagination(next: nil)
            }
            
            do {
                let object = try JSONDecoder().decode(T.Response.self, from: data)
                completion(.success((object, pagination)))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        return task
    }
}
