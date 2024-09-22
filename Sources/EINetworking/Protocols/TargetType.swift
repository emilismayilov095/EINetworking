//
//  File.swift
//  
//
//  Created by Muslim on 15.02.24.
//

import Foundation

public typealias QueryItems = (key: String, value: String?)

public protocol TargetType {
    var url: URL { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var parameters: Encodable? { get }
    var headers: [String: String] { get }
    var encodingType: EncodingType { get }
    var timeOut: TimeInterval { get }
    var queryItems: [QueryItems] { get }
}

public extension TargetType {
    var timeOut: TimeInterval {
        return 120
    }
    
    var queryItems: [QueryItems] {
        return []
    }
    
    var encodingType: EncodingType {
        return .json
    }
    
    func asURLRequest() -> URLRequest {
        var urlWithPath = url.appending(path: path)
        var urlRequest = URLRequest(url: urlWithPath)
        
        urlRequest.httpMethod = httpMethod.rawValue
        
        headers.forEach({ (header: (key: String, value: String)) in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        })
        
        if encodingType == .json {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let body = parameters {
            do {
                let encoder = JSONEncoder()
                
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                print("\(#function) Error encoding data:\nError: \(error)")
            }
            
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

