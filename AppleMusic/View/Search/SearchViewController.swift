//
//  SearchViewController.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {
    
    let trackDetailVM = TrackDetailViewModel()
    let viewModel = SearchViewModel()
    let networkDataFetch = NetworkDataFetcher()
    let searchViewModel = SearchCell()
    
    var searchModel = SearchCellViewModel.init(cells: [])
    
    private var timer: Timer?
    private let activityIndicator = UIActivityIndicatorView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConstraints()
        setupTableView()
        createSearchBar()
        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Поиск"
      
        createActivity()
       
        bindViewModel()
        trackDetailVM.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //bindViewModel()
        
    }
    
    private func createSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .systemRed
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Артиситы, песни, тексты и др.", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        searchController.searchBar.searchTextField.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .lightGray
        
    }
    
   private func tableViewConstraints() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
   private func createActivity() {
        activityIndicator.color = .gray
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)

    }
    
    private func bindViewModel() {
        viewModel.isLoading.bind { [weak self] isLoading in
            guard let self, let isLoading else { return }
            DispatchQueue.main.async {
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.cellDataSource.bind { [weak self] tracks in
            guard let self, let tracks else { return }
            self.searchModel.cells = tracks
            self.reloadTableView()
        }
    }
    

}

// MARK: - Search Bar Delegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        viewModel.updateSearchController(searchBarText: searchController.searchBar.text)

            }
            
        }
    
// MARK: - Player next/forward button settings
    
extension SearchViewController: TrackMovingDelegate {

    func getTrack(isForwardTrack: Bool) -> SearchCellViewModel.Cell? {

        guard let indexPath = tableView.indexPathForSelectedRow else { return nil}
        tableView.deselectRow(at: indexPath, animated: true)

        var nextIndexPath: IndexPath!


        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == searchModel.cells.count {
                nextIndexPath.row = 0
            }

        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = searchModel.cells.count - 1
            }
        }

        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = searchModel.cells[nextIndexPath.row]
        return cellViewModel

    }
    
    func moveForward() -> SearchCellViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }

    func moveBack() -> SearchCellViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }
    
    
}
