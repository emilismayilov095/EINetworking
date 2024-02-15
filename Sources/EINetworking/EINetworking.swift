import Foundation

public struct EINetworking {
    public static let shared = EINetworking()
    private init() {}
    
    func asyncRequest<T: Decodable>(_ target: TargetType,
                               dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                               keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: target.asURLRequest())
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidResponseStatus
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch (let error){
                throw APIError.decodingError(error.localizedDescription)
            }
            
        } catch {
            throw APIError.dataTaskError(error.localizedDescription)
        }
    }
}


extension EINetworking {
    public func set(baseURL: String) {
        BASE_URL = baseURL
    }
}
