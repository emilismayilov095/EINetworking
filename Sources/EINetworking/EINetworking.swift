import Foundation

public struct EINetworking {
    public static let shared = EINetworking()
    private init() {}
    
    public func dispatchRequest<T: Decodable>(target: TargetType,
                                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                              completion: @escaping (Result<T, APIError>) -> Void) {
        
        URLSession.shared.dataTask(with: target.asURLRequest()) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponseStatus))
                return
            }
            
            guard error == nil else {
                completion(.failure(.dataTaskError(error?.localizedDescription ?? "unknown error")))
                return
            }
            
            guard let data = data else {
                completion(.failure(.corruptData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            
            DispatchQueue.main.async {
                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch (let error){
                    completion(.failure(.decodingError(error.localizedDescription)))
                    return
                }
            }
            
        }
        .resume()
    }
    
    public func asyncRequest<T: Decodable>(target: TargetType,
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
