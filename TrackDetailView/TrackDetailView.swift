//
//  TrackDetailView.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 16/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForNextTrack() -> SearchViewModel.Cell?
}


class TrackDetailView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var trackImageView: UIImageView!
    @IBOutlet var currentTimeSlider: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var trackTitleLabel: UILabel!
    @IBOutlet var authorTitleLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var volumeSlider: UISlider!
    
    // MARK: - Outlets For Handling MiniPlayer
    @IBOutlet var miniTrackView: UIView!
    @IBOutlet var miniGoForwardButton: UIButton!
    @IBOutlet var maximizedStackView: UIStackView!
    @IBOutlet var miniTrackImageView: UIImageView!
    @IBOutlet var miniTrackTitleLabel: UILabel!
    @IBOutlet var miniPlayPauseButton: UIButton!
    
    
    // MARK: - Properties
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    // MARK: - AwakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        setupGestures()
}

    // MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        miniTrackTitleLabel.text = viewModel.trackName
//        miniPlayPauseButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        miniPlayPauseButton.imageEdgeInsets = .init(top: 11, left: 11, bottom: 11, right: 11)
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600") ?? ""
        guard let imageUrl = URL(string: string600) else { return }
        miniTrackImageView.sd_setImage(with: imageUrl, completed: nil)
        trackImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    private func setupGestures() {
        
        let miniTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized))
        miniTrackView.addGestureRecognizer(miniTapGesture)
        
        let miniPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanMaximized))
        miniTrackView.addGestureRecognizer(miniPanGesture)
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDissmissalPan)))
        
    }
    
       
    private func playTrack(previewUrl: String?) {
       
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    // MARK: - Maximize / Minimize gestures
    
    @objc private func handleTapMaximized() {
            print("Tap In Action")
            self.tabBarDelegate?.maximizeTrackDetailView(viewModel: nil)
        }
        
    @objc private func handlePanMaximized(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        print("Pan Gesture IN ACTION", translation.y)
            
        switch gesture.state {

        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print("UNKNOWN DEFAULT")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizeTrackDetailView(viewModel: nil)

            } else {

                self.miniTrackView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
//            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func handleDissmissalPan(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.superview)
        
        switch gesture.state {
            
        case .changed:
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        case .ended:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity
                
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizeTrackDetailView()
                }
            }, completion: nil)
            
        @unknown default:
            print("DISMISS PAN - UNKNOWN CASE")
        }
    }
    
      
    // MARK: - Time Setup
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            // здесь добавили ' [weak self] in '  - иначе при скрытии вью (нажатии на кнопку с методом dragDownButtonTapped происходит утечка памяти и трек играет даже после исчезновения данного вью с экрана - то есть из памяти он не выгрузился)
            [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = currentDurationText
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
    }
    
    // MARK: - Animations
    
    private func enlargeTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                self.trackImageView.transform = .identity
            },
            completion: nil)
        
    }
    
    private func reduceTrackImageView() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: .curveEaseInOut,
            animations: {
                let scale: CGFloat = 0.8
                self.trackImageView.transform = .init(scaleX: scale, y: scale)
        },
            completion: nil)
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    
// MARK: - @IBActions
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {

        tabBarDelegate?.minimizeTrackDetailView()
//        self.removeFromSuperview()
        
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveBackForPreviousTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveForwardForNextTrack()
        guard let cellInfo = cellViewModel else { return }
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
            reduceTrackImageView()
        }
    }
    
}
