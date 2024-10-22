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
    var playerLayer:AVPlayerLayer!
    
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var slider: UISlider!
    
    let skipInterval: Double = 10
    
    var player = AVPlayer()
    var timeObserverToken: Any?
    
    var itemDuration: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "sample", withExtension: "mp4")!
        playerItem = AVPlayerItem(url: url)
//        // 状態監視
//        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
//        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)

        self.player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        // 表示モードの設定
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale

        self.playerView.playerLayer = self.playerLayer
        self.playerView.layer.insertSublayer(playerLayer, at: 0)
        
        // Do any additional setup after loading the view.
        setupAudioSession()
        
        setupPlayer()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        do {
            try audioSession.setActive(true)
            print("audio session set active !!")
        } catch {
            
        }
    }
    
    private func setupPlayer() {
        playerView.playerLayer?.player = player
        addPeriodicTimeObserver()
        
        replacePlayerItem(fileName: "sample", fileExtension: "mp4")
        
    }

    private func replacePlayerItem(fileName: String, fileExtension: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Url is nil")
            return
        }
    
        let asset = AVAsset(url: url)
//        itemDuration = CMTimeGetSeconds(asset.duration)
        Task {
            itemDuration = try await CMTimeGetSeconds(asset.load(.duration))
        }
    
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
    }
  

    @IBAction func playBtnTapped(_ sender: Any) {
        player.play()
    }
    
    @IBAction func pauseBtnTapped(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let seconds = Double(sender.value) * itemDuration
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds, preferredTimescale: timeScale)
        
        changePosition(time: time)
    }
    
    @IBAction func skipForwardBtnTapped(_ sender: Any) {
        skipForward()
    }
    
    @IBAction func skipBackwardBtnTapped(_ sender: Any) {
        skipBackward()
    }
    
    private func skipForward() {
        skip(interval: skipInterval)
    }
    
    private func skipBackward() {
        skip(interval: -skipInterval)
    }
    
    private func skip(interval: Double) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let rhs = CMTime(seconds: interval, preferredTimescale: timeScale)
        let time = CMTimeAdd(player.currentTime(), rhs)
        
        changePosition(time: time)
    }
    
    private func updateSlider() {
        let time = player.currentItem?.currentTime() ?? CMTime.zero
        if itemDuration != 0 {
            slider.value = Float(CMTimeGetSeconds(time) / itemDuration)
        }
    }
    
    private func changePosition(time: CMTime) {
        let rate = player.rate
        // いったんplayerをとめる
        player.rate = 0
        // 指定した時間へ移動
        player.seek(to: time, completionHandler: {_ in
            // playerをもとのrateに戻す(0より大きいならrateの速度で再生される)
            self.player.rate = rate
        })
    }
    
    // MARK: Periodic Time Observer
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.001, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main)
        { [weak self] time in
            // update player transport UI
            DispatchQueue.main.async {
                print("update timer:\(CMTimeGetSeconds(time))")
                // sliderを更新
                self?.updateSlider()
            }
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
}

