//
//  NetworkRequest.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import Foundation

class NetworkRequest {
    
    static let shared = NetworkRequest()
    func request(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
                
                
            }
        }.resume()
        
        
    }
}
