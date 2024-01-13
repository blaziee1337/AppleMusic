//
//  LibraryViewController + Tableview.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 06.12.2023.
//

import UIKit
import CoreData


extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
    }

    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func registerCell() {
        tableView.register(SearchCell.register(), forCellReuseIdentifier: SearchCell.identifier)

        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let addedCell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as? SearchCell else { return UITableViewCell()}
            let model = models[indexPath.row]
            addedCell.addedSetupCell(viewModel: model)
            addedCell.backgroundColor = .black
            return addedCell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = models[indexPath.row]
        trackDetailVM.startPlaybackForAddedTracks(self, viewModel: cellViewModel)
       
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
        
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: nil, message: "Вы действительно хотите удалить эту песню из своей медиатеки?", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "Удалить песню", style: .default) { _ in
                self.context.delete(self.models[indexPath.row] as NSManagedObject)
                try? self.context.save()
                tableView.beginUpdates()
                self.models.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            }
            
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
            alertController.addAction(action)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            
        }
    }
}
    

