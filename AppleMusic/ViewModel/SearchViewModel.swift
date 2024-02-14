//
//  SearchViewModel.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 23.09.2023.
//

import UIKit

class SearchViewModel {
    
    var searchResponse: SearchReponse?
    var tracks = [Track]()
    var isLoading: Observable<Bool> = Observable(false)
    var cellDataSource: Observable<[SearchCellViewModel.Cell]> = Observable(nil)
    var timer: Timer?
    
    private func getTracks(_ searchText: String) {
        isLoading.value = true
        
        let urlString = "https://itunes.apple.com/search?term=\(searchText)&entity=song"
        NetworkDataFetcher.shared.fetchSongs(urlString: urlString) { [weak self] searchResponse, error in
            if error == nil {
                
                guard let searchResponse = searchResponse else { return }

                let sortedTracks = searchResponse.results.sorted { firstItem, secondItem in

                    return firstItem.trackName.compare(secondItem.trackName) == ComparisonResult.orderedAscending
                }
                self?.tracks = sortedTracks
                self?.isLoading.value = false
                self?.mapCellData()
                
                
            } else {
                print(error!.localizedDescription)
            }
            
        }
        
    }
    
    private func mapCellData() {
        cellDataSource.value = tracks.compactMap({ (track) in
            cellViewModel(from: track)
        })
    }
    
    private func cellViewModel(from track: Track) -> SearchCellViewModel.Cell {
        return SearchCellViewModel.Cell.init(trackName: track.trackName,
                                             artistName: track.artistName,
                                             collectionName: track.collectionName,
                                             iconUrlString: track.artworkUrl100,
                                             trackURL: track.previewUrl)
        
    }
}

extension SearchViewModel {
    
    func updateSearchController(searchBarText: String?) {
        let text = searchBarText?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.getTracks(text!)
            
        })
    }
}

