//
//  TrackCell.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 14/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftUI

protocol TrackCellViewModel {
    var iconUrlString: String? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
    
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"

    @IBOutlet var trackImageView: UIImageView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var collectionNameLabel: UILabel!
    @IBOutlet var addTrackButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
    }
    
    var cell: SearchViewModel.Cell?
    
    func set(viewModel: SearchViewModel.Cell) {

        cell = viewModel
        
        let listOfTracks = UserDefaults.standard.getTracks()
        let hasFavourite = listOfTracks.firstIndex(where: {
            $0.trackName == cell?.trackName  &&  $0.artistName == cell?.artistName
        }) != nil
        if hasFavourite {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        print("GET CELL: \(cell?.trackName ?? "")")
        
             trackNameLabel.text = cell?.trackName
            artistNameLabel.text = cell?.artistName
        collectionNameLabel.text = cell?.collectionName
        
        guard let imageUrl = URL(string: viewModel.iconUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    @IBAction func addTrackAction(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        guard let cell = cell else { return }
        addTrackButton.isHidden = true
        
        var listOfTracks = [SearchViewModel.Cell]()
        
        listOfTracks = defaults.getTracks()
        
        listOfTracks.append(cell)
        
        defaults.saveTracks(listOfTracks: listOfTracks)
        
    }
}
