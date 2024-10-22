//
//  PlayerView.swift
//  CustomVideoPlayer
//
//  Created by 田島隼也 on 2024/10/22.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    var playerLayer:AVPlayerLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
}

