//
//  UserDefaults + Extension.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 27/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favouriteTrackKey = "favouriteTrackKey"
    
    func getTracks() -> [SearchViewModel.Cell] {
        

        let defaults = UserDefaults.standard
        
        guard let savedTracks = defaults.object(forKey: UserDefaults.favouriteTrackKey) as? Data else { return [] }
        guard let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedTracks) as? [SearchViewModel.Cell] else { return [] }
        return decodedTracks
    }
    
    
    func saveTracks(listOfTracks: [SearchViewModel.Cell]) {
        let defaults = UserDefaults.standard
        guard let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) else { return }
        defaults.set(archivedData, forKey: UserDefaults.favouriteTrackKey)
    }
}
