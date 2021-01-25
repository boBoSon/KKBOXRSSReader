//
//  PlayerControlView.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/23.
//

import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class PlayerControlView: UIView {
    let vm = PlayerControlViewModel()
    let bag = DisposeBag()
    
    var trackSlider: UISlider!
    var pauseBtn: UIButton!
    var fastForwardBtn: UIButton!
    var rewindBtn: UIButton!
    var loadingView: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        trackSlider = UISlider()
        trackSlider.tintColor = UIColor(red: 58.0/255.0, green: 140.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        addSubview(trackSlider)
        pauseBtn = UIButton()
        pauseBtn.setImage(UIImage(named: "Pause"), for: .normal)
        pauseBtn.setImage(UIImage(named: "Play"), for: .selected)
        pauseBtn.isSelected = true
        addSubview(pauseBtn)
        fastForwardBtn = UIButton()
        fastForwardBtn.setImage(UIImage(named: "FastForward"), for: .normal)
        addSubview(fastForwardBtn)
        rewindBtn = UIButton()
        rewindBtn.setImage(UIImage(named: "Rewind"), for: .normal)
        addSubview(rewindBtn)
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        addSubview(loadingView)
        
        #if targetEnvironment(simulator)
        pauseBtn.backgroundColor = .orange
        fastForwardBtn.backgroundColor = .red
        rewindBtn.backgroundColor = .red
        #endif
        
        bindModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackSlider.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(30.0)
        }
        
        pauseBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(120.0)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).inset(10.0)
        }
        
        rewindBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(90.0)
            make.centerY.equalTo(pauseBtn)
            make.left.equalTo(self)
        }
        
        fastForwardBtn.snp.makeConstraints { (make) in
            make.width.height.centerY.equalTo(rewindBtn)
            make.right.equalTo(self)
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        
    }
    
    func bindModel() {
        vm.playerItemStatus.asObservable().subscribe(onNext: { [weak self] (statusRawValue) in
            // config slider
            guard let strongSelf = self, let player = strongSelf.vm.player else { return }
            var interval: Double = 0.1
            let playerDuration = strongSelf.vm.playerItemDuration()
            guard playerDuration.isValid else { return }
            // load finished, auto play
            DispatchQueue.main.async {
                self?.loadingView.stopAnimating()
                self?.pauseBtn.isSelected = false
            }
            
            // register time observer
            let duration = playerDuration.seconds
            if duration.isFinite {
                let width = Double(strongSelf.trackSlider.bounds.width)
                interval = 0.5 * duration / width
            }
            strongSelf.vm.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: interval, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] (_) in
                self?.syncScrubber()
            })
            
            // register end observer
            let endTime = NSValue(time: playerDuration - CMTimeMakeWithSeconds(0.1, preferredTimescale: playerDuration.timescale))
            strongSelf.vm.endObserver = player.addBoundaryTimeObserver(forTimes: [endTime], queue: .main, using: { [weak self] in
                guard let timeObserver = self?.vm.timeObserver, let endObserver = self?.vm.endObserver else { return }
                self?.vm.player?.removeTimeObserver(timeObserver)
                self?.vm.timeObserver = nil
                self?.vm.player?.removeTimeObserver(endObserver)
                self?.vm.endObserver = nil
                if let currentIdx = self?.vm.currentIdx.value, currentIdx > 0 {
                    self?.vm.currentIdx.accept(currentIdx - 1)
                    DispatchQueue.main.async {
                        self?.loadingView.startAnimating()
                        self?.pauseBtn.isSelected = true
                    }
                }
            })
            
            player.play()
        }).disposed(by: bag)
        
        // 20210125 Updated by Bo
        // Fixed the bug that player would repeat a little piece of track (both UI and the audio) after updating track slider value.
        /*
        trackSlider.rx.value.debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (value) in
            guard let slider = self?.trackSlider, let player = self?.vm.player, let duration = player.currentItem?.duration else { return }
            let percent = value / (slider.maximumValue - slider.minimumValue)
            let toBeSec = duration.seconds * Double(percent)
            self?.vm.stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTimeMakeWithSeconds(toBeSec, preferredTimescale: duration.timescale))
            self?.vm.shouldJumpUpdatingTrackSlider = true
        }).disposed(by: bag)
        */
        trackSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        // 20210125 end of update
        
        pauseBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let player = self?.vm.player else { return }
            if player.timeControlStatus == .playing {
                player.pause()
                self?.pauseBtn.isSelected = true
            } else {
                player.play()
                self?.pauseBtn.isSelected = false
            }
        }).disposed(by: bag)
        
        fastForwardBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let playerDuration = self?.vm.playerItemDuration(), playerDuration.isValid, let player = self?.vm.player else { return }
            let toBeSec = player.currentTime().seconds.advanced(by: 15.0)
            player.seek(to: CMTimeMakeWithSeconds(toBeSec, preferredTimescale: player.currentTime().timescale))
            DispatchQueue.main.async {
                self?.syncScrubber()
            }
        }).disposed(by: bag)
        
        rewindBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let playerDuration = self?.vm.playerItemDuration(), playerDuration.isValid, let player = self?.vm.player else { return }
            let toBeSec = player.currentTime().seconds.advanced(by: -15.0)
            player.seek(to: CMTimeMakeWithSeconds(toBeSec, preferredTimescale: player.currentTime().timescale))
            DispatchQueue.main.async {
                self?.syncScrubber()
            }
        }).disposed(by: bag)
    }
    
    func syncScrubber() {
        guard !vm.shouldJumpUpdatingTrackSlider else {
//            vm.shouldJumpUpdatingTrackSlider = false
            return
        }
        let playerDuration = self.vm.playerItemDuration()
        guard playerDuration.isValid else {
            trackSlider.minimumValue = 0
            return
        }
        let duration = playerDuration.seconds
        if duration.isFinite && duration > 0, let time = vm.player?.currentTime().seconds {
            let minValue = trackSlider.minimumValue
            let maxValue = trackSlider.maximumValue
            trackSlider.value = (maxValue - minValue) * Float(time / duration) + minValue
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        loadingView.startAnimating()
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                vm.shouldJumpUpdatingTrackSlider = true
            case .ended:
                guard let player = vm.player, let duration = player.currentItem?.duration else { return }
                let percent = slider.value / (slider.maximumValue - slider.minimumValue)
                let toBeSec = duration.seconds * Double(percent)
                vm.stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTimeMakeWithSeconds(toBeSec, preferredTimescale: duration.timescale)) { [weak self] in
                    DispatchQueue.main.async {
                        self?.pauseBtn.isSelected = false
                    }
                }
            default:
                break
            }
        }
    }

}
