//
//  SearchViewController.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 10/10/2019.
//  Copyright (c) 2019 Dmitry Filippov. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: class {
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {

    
  var interactor: SearchBusinessLogic?
  var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    let searchController = UISearchController()
    
    private var searchViewModel = SearchViewModel.init(cells: [])
    private var timer: Timer?
    
    private lazy var footerView = FooterView()

    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    @IBOutlet var table: UITableView!

  
  // MARK: Setup
  
  private func setup() {
    let viewController        = self
    let interactor            = SearchInteractor()
    let presenter             = SearchPresenter()
    let router                = SearchRouter()
    viewController.interactor = interactor
    viewController.router     = router
    interactor.presenter      = presenter
    presenter.viewController  = viewController
    router.viewController     = viewController
  }
  
  // MARK: Routing
  

  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupTableView()
    setupSearchBar()
    searchBar(searchController.searchBar, textDidChange: "pixies")
  }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let keyWindow = UIApplication.shared.connectedScenes
            .filter ({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackDetailView.delegate = self
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // чтобы при активации searchBar'а экран не затемнялся
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        
        table.tableFooterView = footerView
    }
    
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
    switch viewModel {
    
    case .displayTracks(let searchViewModel):
        print("viewModel .displayTracks")
        self.searchViewModel = searchViewModel
        table.reloadData()
        footerView.hideLoader()
        
    case .displayFooterView:
        footerView.showLoader()
    }
  }
}

// MARK: - TableViewDelegate,  TableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
        
        let cellViewModel = searchViewModel.cells[indexPath.row]

        cell.trackImageView.backgroundColor = .red
        cell.set(viewModel: cellViewModel)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = searchViewModel.cells[indexPath.row]
        
        tabBarDelegate?.maximizeTrackDetailView(viewModel: cellViewModel)
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
                                                
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModel.cells.count > 0 ? 0 : 250
    }
}

// MARK: - SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
}

// MARK: - TrackMovingDelegate
extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        guard let indexPath = table.indexPathForSelectedRow else { return nil }  
        table.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == searchViewModel.cells.count {
                nextIndexPath = IndexPath(row: 0, section: indexPath.section)
            }

        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                let nextRow = searchViewModel.cells.count - 1
                nextIndexPath = IndexPath(row: nextRow, section: indexPath.section)
            }
        }
        table.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = searchViewModel.cells[nextIndexPath.row]
        return cellViewModel
    }

    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }

    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }
}
