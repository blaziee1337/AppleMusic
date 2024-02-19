//
//  SearchCellViewModel.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 26.09.2023.
//

import Foundation

struct SearchCellViewModel {
    
    var cells: [Cell]
}
struct Cell: TrackCellViewModel {
    var trackName: String
    
    var artistName: String
    
    var collectionName: String
    
    var iconUrlString: String?
    
    var trackURL: String

}

