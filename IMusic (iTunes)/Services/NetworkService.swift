//
//  NetworkService.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 08/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
    func fetchTracks(searchText: String, completion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": "\(searchText)",
                         "limit": "100",
                         "media": "music"]
        AF.request(url, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: nil).responseData { (dataResponse) in

            if let error = dataResponse.error {
                print("Received Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = dataResponse.data else { return }

            let decoder = JSONDecoder()
            do {
                let objects = try decoder.decode(SearchResponse.self, from: data)
//                print(objects)
                completion(objects)
            } catch let jsonError {
                completion(nil)
                print ("Failed to decode JSON", jsonError)
            }
        }
    }
}
