//
//  CMTime + Extension.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 19/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import Foundation
import AVKit

extension CMTime {
    func toDisplayString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else { return "" }
        // получаем количество секунд в треке
        let totalSeconds = Int( CMTimeGetSeconds(self) )
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
