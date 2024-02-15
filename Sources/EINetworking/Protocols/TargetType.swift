//
//  File.swift
//  
//
//  Created by Muslim on 15.02.24.
//

import Foundation

var BASE_URL = ""
public typealias QueryItems = (key: String, value: String?)

public protocol TargetType {
    var url: URL { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var parameters: Data? { get }
    var headers: [String: String] { get }
    var timeOut: TimeInterval { get }
    var parametersExetension: [String: Any] { get }
    var queryItems: [QueryItems] { get }
}

extension TargetType {
    var url: URL {
        guard let url = URL(string: BASE_URL) else { fatalError("please add baseURL") }
        return url
    }
    
    var timeOut: TimeInterval {
        return 120
    }
    
    func asURLRequest() -> URLRequest {
        var urlWithPath = url.appendingPathComponent(path)
        var urlRequest = URLRequest(url: urlWithPath)
        
        urlRequest.httpMethod = httpMethod.rawValue
        
        headers.forEach({ (header: (key: String, value: String)) in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        })
        
        if let body = parameters {
            urlRequest.httpBody = body
        }
        
        if !queryItems.isEmpty {
            queryItems.forEach { (key, value) in
                urlWithPath = urlWithPath.appending(key, value: value)
            }
        }
        
        urlRequest.timeoutInterval = timeOut
        urlRequest.cachePolicy = .reloadIgnoringCacheData // .returnCacheDataDontLoad
        
        return urlRequest
    }
}
