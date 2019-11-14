//
//  SearchModels.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 10/10/2019.
//  Copyright (c) 2019 Dmitry Filippov. All rights reserved.
//

import UIKit

enum Search {
   
  enum Model {
    struct Request {
      enum RequestType {
        case getTracks(searchTerm: String)
      }
    }
    struct Response {
      enum ResponseType {
        case presentTracks(searchResponse: SearchResponse?)
        case presentFooterView
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayTracks(searchViewModel: SearchViewModel)
        case displayFooterView
      }
    }
  }
}


class SearchViewModel: NSObject, NSCoding{
    func encode(with coder: NSCoder) {
        coder.encode(cells, forKey: "cells")
    }
    
    required init?(coder: NSCoder) {
        cells = coder.decodeObject(forKey: "cells") as? [SearchViewModel.Cell] ?? []
    }
    
    @objc(_TtCC15IMusic__iTunes_15SearchViewModel4Cell)class Cell: NSObject, NSCoding, Identifiable {
        
//        let id = UUID()
        
        var iconUrlString: String?
        var trackName: String
        var collectionName: String
        var artistName: String
        var previewUrl: String?
        
        func encode(with coder: NSCoder) {
            coder.encode(iconUrlString, forKey: "iconUrlString")
            coder.encode(trackName, forKey: "trackName")
            coder.encode(collectionName, forKey: "collectionName")
            coder.encode(artistName, forKey: "artistName")
            coder.encode(previewUrl, forKey: "previewUrl")
        }
        
        required init?(coder: NSCoder) {
            self.iconUrlString  = coder.decodeObject(forKey: "iconUrlString") as? String? ?? ""
            self.trackName      = coder.decodeObject(forKey: "trackName") as? String ?? ""
            self.collectionName = coder.decodeObject(forKey: "collectionName") as? String ?? ""
            self.artistName     = coder.decodeObject(forKey: "artistName") as? String ?? ""
            self.previewUrl     = coder.decodeObject(forKey: "previewUrl") as? String? ?? ""
            
        }
        
        
        init(
            iconUrlString: String?,
            trackName: String,
            collectionName: String,
            artistName: String,
            previewUrl: String?
        ) {
            self.iconUrlString = iconUrlString
            self.trackName = trackName
            self.collectionName = collectionName
            self.artistName = artistName
            self.previewUrl = previewUrl
        }
    }
    
    let cells: [Cell]
    
    init(cells: [Cell]) {
        self.cells = cells
    }
}
