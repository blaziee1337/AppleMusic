//
//  SearchResponse.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import Foundation

struct SearchReponse: Decodable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Decodable {
    let trackName: String
    let artworkUrl100: String?
    let collectionName: String
    let artistName: String
    var previewUrl: String

}
