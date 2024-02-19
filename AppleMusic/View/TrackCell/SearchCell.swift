//
//  SearchCell.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 27.09.2023.
//

import UIKit
import CoreData

protocol TrackCellViewModel {
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
    var iconUrlString: String? { get }
    var trackURL: String { get }
}

final class SearchCell: UITableViewCell {
    
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest = AddedTracks.fetchRequest()
    
    var cell: SearchCellViewModel.Cell?
    static var identifier = "SearchCell"
    static func register() -> UINib {
        UINib(nibName: "SearchCell", bundle: nil)
    }
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    
    @IBAction func addButtonAction(_ sender: Any) {
        checkTrack()
    }
    
    private func addTracks() {
        let addedTracks = AddedTracks(context: self.context)
        addedTracks.trackName = cell?.trackName
        addedTracks.collectionName = cell?.collectionName
        addedTracks.previewUrl = cell?.trackURL
        addedTracks.trackImage = cell?.iconUrlString
        addedTracks.artistName = cell?.artistName
        if context.hasChanges {
            do {
                context.insert(addedTracks)
                try context.save()
                
            } catch {
                context.rollback()
                fatalError()
            }
        }
    }
    
    func setupCell(viewmodel: SearchCellViewModel.Cell) {
        self.cell = viewmodel
        fetchRequest.predicate = NSPredicate(format: "trackName = %@ AND artistName =%@ AND collectionName = %@", argumentArray: [cell!.trackName, cell!.artistName, cell!.collectionName])
        let count = try? context.count(for: fetchRequest)
        if count! > 0 {
            addButton.isHidden = true
            
        } else {
            addButton.isHidden = false
            
        }
        
        trackNameLabel.text = viewmodel.trackName
        artistNameLabel.text = viewmodel.artistName
        collectionNameLabel.text = viewmodel.collectionName
        
        guard let url = viewmodel.iconUrlString else { return }
        setImage(urlString: url)
    }
    
    private func setImage(urlString: String?) {
        DispatchQueue.global().async {
            
        if let urlString = urlString {
            NetworkRequest.shared.request(urlString: urlString) { [weak self] result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            
                            let image = UIImage(data: data)
                            self?.trackImageView.image = image
                        }
                    case .failure(let error):
                        self?.trackImageView.image = UIImage(systemName: "questionmark")
                        print("No album logo:", error.localizedDescription)
                        
                    }
                    
                }
            } else {
                self.trackImageView.image = UIImage(systemName: "questionmark")
            }
        }
    }
    
    private func checkTrack() {
        fetchRequest.predicate = NSPredicate(format: "trackName = %@ AND artistName =%@ AND collectionName = %@", argumentArray: [cell!.trackName, cell!.artistName, cell!.collectionName])
        
        let count = try? context.count(for: fetchRequest)
        do {
            if count! == 0 {
                addTracks()
                addButton.isHidden = true
            } else {
                let objects = try context.fetch(fetchRequest)
                for object in objects {
                    context.delete(object)
                }
                try context.save()
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error)")
            return
        }
    }
    
    func addedSetupCell(viewModel: AddedTracks) {
        addButton.isHidden = true
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        collectionNameLabel.text = viewModel.collectionName
        guard let url = viewModel.trackImage else { return }
        setImage(urlString: url)
        
    }
}

