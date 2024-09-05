import Foundation

public struct EINetworking {
    public static let shared = EINetworking()
    private init() {}
    
    public func dispatchRequest<T: Decodable>(target: TargetType,
                                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                              withLogs: Bool = true,
                                              completion: @escaping (Result<T, APIError>) -> Void) {
        
        URLSession.shared.dataTask(with: target.asURLRequest()) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, (200...202).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponseStatus("\((response as? HTTPURLResponse)?.statusCode ?? 0)")))
                return
            }
            
            guard error == nil else {
                if withLogs {
                    print("---- DATA TASK ERROR ------------------------")
                    print(error?.localizedDescription ?? "unknown error")
                    print("---- DATA TASK ERROR --------------------------")
                }
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
                    if withLogs {
                        print("---- DECODING ERROR ------------------------")
                        print(String(describing: error))
                        print("---- DECODING ERROR --------------------------")
                    }
                    completion(.failure(.decodingError(error.localizedDescription)))
                    return
                }
            }
            
            if withLogs {
                print("---- REQUEST BEGIN ------------------------")
                print("URL:         ", target.path)
                print("HEADERS:     ", target.headers)
                print("PARAMS:      ", target.parameters ?? [:])
                print("RESPONSE:    ","\(data.prettyPrintedJSONString ?? "")")
                print("---- REQUEST END --------------------------")
            }
            
        }
        .resume()
    }
    
    public func asyncRequest<T: Decodable>(target: TargetType,
                               dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                               keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                           withLogs: Bool = true) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: target.asURLRequest())
            guard let httpResponse = response as? HTTPURLResponse, (200...202).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponseStatus("\((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            
            if withLogs {
                print("---- REQUEST BEGIN ------------------------")
                print("URL:         ", target.path)
                print("HEADERS:     ", target.headers)
                print("PARAMS:      ", target.parameters ?? [:])
                print("RESPONSE:    ","\(data.prettyPrintedJSONString ?? "")")
                print("---- REQUEST END --------------------------")
            }
            
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
