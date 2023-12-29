//
//  NetworkDataFetch.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 22.09.2023.
//

import Foundation

class NetworkDataFetcher {
    
    static let shared = NetworkDataFetcher()
    let networkService = NetworkRequest()
    
     func fetchSongs(urlString: String, response: @escaping (SearchReponse?, Error?) -> Void) {
        networkService.request(urlString: urlString) { (result) in
            switch result {
                
            case .success(let data):
                do {
                    let tracks = try JSONDecoder().decode(SearchReponse.self, from: data)
                    response(tracks, nil)
                    
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    
                }
            case .failure(let error):
                print("Error received request data: \(error.localizedDescription)")
                response(nil, error)
            }
        }
    }
}
