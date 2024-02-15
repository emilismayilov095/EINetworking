//
//  File.swift
//  
//
//  Created by Muslim on 16.02.24.
//

import Foundation


public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus(String)
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid", comment: "")
        case .invalidResponseStatus(let string):
            return NSLocalizedString("\(string) status code is invalid ", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("The data is corrupt", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}
