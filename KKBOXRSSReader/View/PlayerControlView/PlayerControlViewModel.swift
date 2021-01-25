//
//  PlayerControlViewModel.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/23.
//

import Foundation
import AVKit
import RxSwift
import RxCocoa
import Alamofire

class PlayerControlViewModel: NSObject {
    var player: AVPlayer?
    var eps = [Episode]()
    var currentIdx: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    private var playerItemContext = 0
    var playerItemStatus: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    let bag = DisposeBag()
    var timeObserver: Any?
    var endObserver: Any?
    var shouldJumpUpdatingTrackSlider = false
    var isSeekInProgress = false
    var chaseTime = CMTime.zero
    
    override init() {
        super.init()
        bindModel()
    }
    
    func bindModel() {
        currentIdx.subscribe(onNext: { [weak self] (currentIdx) in
            guard let strongSelf = self, currentIdx < strongSelf.eps.count else { return }
            weak var ep = strongSelf.eps[currentIdx]
            if ep!.content == nil {
                AF.request(ep!.contentURL).responseData { [weak self] (response) in
                    switch response.result {
                    case .success(let data):
                        ep?.content = data
                        self?.currentIdx.accept(currentIdx)
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                guard let strongSelf = self, let asset = ep!.content?.getAVAsset() else { return }
                asset.loadValuesAsynchronously(forKeys: ["playable"]) {
                    let item = AVPlayerItem(asset: asset)
                    item.addObserver(strongSelf, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &strongSelf.playerItemContext)
                    DispatchQueue.main.async {
                        strongSelf.player = AVPlayer(playerItem: item)
                    }
                }
            }
        }).disposed(by: bag)
    }
    
    func setPlayerItems(episodes: [Episode]) {
        guard episodes.count > 0 else { return }
        eps = episodes
        currentIdx.accept(eps.count - 1)
    }
    
    func playerItemDuration() -> CMTime {
        guard let item = player?.currentItem, item.status == .readyToPlay else { return .invalid }
        
        return item.duration
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNum = change?[.newKey] as? NSNumber, let aStatus = AVPlayerItem.Status(rawValue: statusNum.intValue) {
                status = aStatus
            } else {
                status = .unknown
            }
            
            playerItemStatus.accept(status.rawValue)
        }
    }
    
    func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime, successCompletion: (() -> Void)? = nil) {
        player?.pause()
        
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime
            
            if !isSeekInProgress {
                trySeekToChaseTime(successCompletion: successCompletion)
            }
        }
    }
    
    private func trySeekToChaseTime(successCompletion: (() -> Void)? = nil) {
        if playerItemStatus.value == 0 {
            // wait until item becomes ready (KVO player.currentItem.status)
        } else if playerItemStatus.value == 1 {
            actuallySeekTotime(successCompletion: successCompletion)
        }
    }
    
    private func actuallySeekTotime(successCompletion: (() -> Void)? = nil) {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player?.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [unowned self] (isFinished) in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
                self.shouldJumpUpdatingTrackSlider = false
                self.player?.play()
                successCompletion?()
            } else {
                self.trySeekToChaseTime()
            }
        })
    }
    
    deinit {
        player?.pause()
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        if let endObserver = endObserver {
            player?.removeTimeObserver(endObserver)
        }
        player = nil
    }
}
