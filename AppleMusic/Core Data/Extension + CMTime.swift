//
//  Extension + CMTime.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 19.12.2023.
//

import Foundation
import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else { return "" }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minus = totalSeconds / 60
        let timeFormattedString = String(format: "%02d:%02d", minus, seconds)
        return timeFormattedString
    }
}

