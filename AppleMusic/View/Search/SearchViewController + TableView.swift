//
//  SearchViewController + TableView.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 23.09.2023.
//

import UIKit

// MARK: - Table settings

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        return searchModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier, for: indexPath) as? SearchCell else { return UITableViewCell()}
        let cellViewModel = searchModel.cells[indexPath.row]
        cell.backgroundColor = .black
        cell.setupCell(viewmodel: cellViewModel)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = searchModel.cells[indexPath.row]
        trackDetailVM.startPlayback(self, viewModel: cellViewModel)
       
    }
}
