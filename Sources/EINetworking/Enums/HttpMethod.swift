//
//  File.swift
//  
//
//  Created by Muslim on 16.02.24.
//

import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


public enum EncodingType {
    case url
    case json
}
