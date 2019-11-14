//
//  SearchMusicTableViewController.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 06/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit
import Alamofire

struct TrackModel {
    var trackName: String
    var artistName: String
}



class SearchMusicTableViewController: UITableViewController {
    
    var networkService = NetworkService()
    
    private var timer: Timer?
    
    let searchController = UISearchController()
    
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSearchBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let track = tracks[indexPath.row]
        cell.textLabel?.text = "\(track.artistName)\n\(track.trackName)"
        cell.textLabel?.numberOfLines = 2
        cell.imageView?.image = UIImage(named: "butthole")
        return cell
    }
}

extension SearchMusicTableViewController: UISearchBarDelegate {
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        let searchText = searchBar.text
//        let url = "https://itunes.apple.com/search"
//        let parameters = ["term": "\(searchText ?? "")",
//            "limit": "10"]
//        AF.request(url, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: nil).responseData { (dataResponse) in
//            print(#line, #function, "AF.request in action")
//            if let error = dataResponse.error {
//                print("Received Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = dataResponse.data else { return }
//
//            let decoder = JSONDecoder()
//            do {
//                let objects = try decoder.decode(SearchResponse.self, from: data)
//                self.tracks = objects.results
//                self.tableView.reloadData()
//
//            } catch let jsonError {
//                print ("Failed to decode JSON", jsonError)
//            }
//
//            print("\(String(data: data, encoding: .utf8) ?? "")")
//        }
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkService.fetchTracks(searchText: searchText) { [weak self] (response) in
                self?.tracks = response?.results ?? []
                self?.tableView.reloadData()
            }
        })
    }
}
