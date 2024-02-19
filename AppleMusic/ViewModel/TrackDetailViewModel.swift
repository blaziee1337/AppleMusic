//
//  TrackDetailViewModel.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 02.10.2023.
//

import UIKit
import AVFoundation
import CoreData

class TrackDetailViewModel {
    
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest = AddedTracks.fetchRequest()
    
    private let trackDetailVC = TrackDetailViewController()
    private let player = AVPlayer()
    
    weak var delegate: TrackMovingDelegate?
    weak var addedDelegate: AddedTrackMovingDelegate?
    
    func startPlayback(_ viewController: UIViewController ,viewModel: SearchCellViewModel.Cell) {
        playTrack(preview: viewModel.trackURL)
        
        trackDetailVC.delegate = self
        trackDetailVC.trackMovingDelegate = self
        
        trackDetailVC.modalPresentationStyle = .overFullScreen
        
        viewController.present(trackDetailVC, animated: true)
        
        trackDetailVC.reloadUI(track: viewModel )
        
    }
    
    func startPlaybackForAddedTracks(_ viewController: UIViewController, viewModel: AddedTracks) {
        playTrack(preview: viewModel.previewUrl)
        
        trackDetailVC.delegate = self
        trackDetailVC.trackMovingDelegate = self
        trackDetailVC.addedDelegate = self
        
        trackDetailVC.modalPresentationStyle = .overFullScreen
        
        viewController.present(trackDetailVC, animated: true)
        trackDetailVC.reloadUIAddedTracks(track: viewModel)
    }
    
    // MARK: - Player setup
    
    private func playTrack(preview: String?) {
                guard let url = URL(string: preview ?? "") else { return }
                let playerItem = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: playerItem)
                player.play()
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                NotificationCenter.default.addObserver(self, selector: #selector(trackDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                NotificationCenter.default.addObserver(self, selector: #selector(addedTrackDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                player.automaticallyWaitsToMinimizeStalling = false
                
            
        
    }
    
    // MARK: - Player moving forward after track ending
    
    @objc func trackDidEnded() {
        let cellViewModel = delegate?.moveForward()
        guard let cellViewModel = cellViewModel else { return }
        trackDetailVC.reloadUI(track: cellViewModel)
        playTrack(preview: cellViewModel.trackURL)
        
    }
    
    @objc func addedTrackDidEnded() {
        let addedCellViewModel = addedDelegate?.moveForward()
        guard let addedCellViewModel = addedCellViewModel else { return }
        trackDetailVC.reloadUIAddedTracks(track: addedCellViewModel)
        playTrack(preview: addedCellViewModel.previewUrl)
    }
}

extension TrackDetailViewModel: TrackDetailViewDelegate {
    
    // MARK: - Buttons setup
    
    func didTapPlayPauseButton() {
        if player.timeControlStatus == .playing {
            player.pause()
           
        } else if player.timeControlStatus == .paused {
            player.play()
            
        }
    }
    
    func dismissButton() {
        trackDetailVC.dismiss(animated: true)
        player.replaceCurrentItem(with: nil)
        
    }
    
    // MARK: - Time setup
    
    func didChangeTime(slider: UISlider) {
        let percentage = slider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1000)
        player.seek(to: seekTime)
        
    }
    
    // MARK: - Slider Setup
    
    func sliderUpdate(slider: UISlider, currentTimeLabel: UILabel, remainingTimeLabel: UILabel) {
        let interval = CMTimeMake(value: 1, timescale: 3)
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationTimeText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            remainingTimeLabel.text = "-\(currentDurationTimeText)"
        }
        let currentTimeSeconds = CMTimeGetSeconds((player.currentTime()))
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        slider.value = Float(percentage)
    }
    
    func didChangeVolume(didSlideVolume value: Float) {
        player.volume = value
    }
}

// MARK: - Player next/forward button settings

extension TrackDetailViewModel: TrackMovingDelegate {
    func moveBack() -> SearchCellViewModel.Cell? {
        let cellViewModel = delegate?.moveBack()
        guard let cellViewModel = cellViewModel else { return nil}
        trackDetailVC.reloadUI(track: cellViewModel)
        playTrack(preview: cellViewModel.trackURL)
        return cellViewModel
        
    }
    
    func moveForward() -> SearchCellViewModel.Cell? {
        let cellViewModel = delegate?.moveForward()
        guard let cellViewModel = cellViewModel else { return nil}
        trackDetailVC.reloadUI(track: cellViewModel)
        playTrack(preview: cellViewModel.trackURL)
        return cellViewModel
        
    }
}

extension TrackDetailViewModel: AddedTrackMovingDelegate {
    func moveBack() -> AddedTracks? {
        let cellViewModel = addedDelegate?.moveBack()
        guard let cellViewModel = cellViewModel else { return nil}
        trackDetailVC.reloadUIAddedTracks(track: cellViewModel)
        playTrack(preview: cellViewModel.previewUrl)
        return cellViewModel
    }
    
    func moveForward() -> AddedTracks? {
        let cellViewModel = addedDelegate?.moveForward()
        guard let cellViewModel = cellViewModel else { return nil}
        trackDetailVC.reloadUIAddedTracks(track: cellViewModel)
        playTrack(preview: cellViewModel.previewUrl)
        return cellViewModel
    }
}







