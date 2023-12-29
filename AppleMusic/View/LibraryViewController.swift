//
//  LibraryViewController.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import UIKit
import SnapKit


final class LibraryViewController: UIViewController {
    
    let trackDetailVM = TrackDetailViewModel()
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        return tableView
    }()
    
    var models = [AddedTracks]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        tableViewConstraints()
        setupTableView()
        reloadTableView()
        getModels()
        
        trackDetailVM.addedDelegate = self
        navigationItem.title = "Песни"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getModels()
    }
    
    // MARK: - Get models from Core Data
    
    private func getModels() {
        do {
            let fetchRequest = AddedTracks.fetchRequest()
            let sectionSortDescriptor = NSSortDescriptor(key: #keyPath(AddedTracks.trackName), ascending: true)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            try models = context.fetch(fetchRequest)
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
            try context.save()
        } catch {
            fatalError()
        }
    }
    
    // MARK: - tableView Constaraints
    
   private func tableViewConstraints() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

// MARK: - Player next/forward button settings

extension LibraryViewController: AddedTrackMovingDelegate {
    private func getTrack(isForwardTrack: Bool) -> AddedTracks? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil}
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == models.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = models.count - 1
            }
        }
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let model = models[nextIndexPath.row]
        return model
    }
    
    func moveBack() -> AddedTracks? {
        return getTrack(isForwardTrack: false)
    }
    
    func moveForward() -> AddedTracks? {
        return getTrack(isForwardTrack: true)
    }
}
