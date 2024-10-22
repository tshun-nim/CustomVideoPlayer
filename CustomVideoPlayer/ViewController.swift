//
//  ViewController.swift
//  CustomVideoPlayer
//
//  Created by 田島隼也 on 2024/10/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var playerItem:AVPlayerItem!
    var avplayer:AVPlayer!
    var playerLayer:AVPlayerLayer!
    
    @IBOutlet var playerView: PlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        playerItem = AVPlayerItem(url: url)
        
        // 状態監視
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

        self.avplayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: avplayer)
        // 表示モードの設定
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale

        self.playerView.playerLayer = self.playerLayer
        self.playerView.layer.insertSublayer(playerLayer, at: 0)
    }

    //画面消える時に監視削除
    deinit{
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    
   //監視イベント
   //Unknown 、ReadyToPlay 、 Failed状態があり、readyToPlayの際のみ再生
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            // TODO
        }else if keyPath == "status"{
            if playerItem.status == AVPlayerItem.Status.readyToPlay{
                self.avplayer.play()
            }else{
                print("error")
            }
        }
    }
}

