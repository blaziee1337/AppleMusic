//
//  TrackDetailViewController.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 30.09.2023.
//

import UIKit
import SnapKit

final class TrackDetailViewController: UIViewController {
    
    weak var delegate: TrackDetailViewDelegate?
    weak var trackMovingDelegate: TrackMovingDelegate?
    weak var addedDelegate: AddedTrackMovingDelegate?
    weak var tabBardelegate: TabBarControllerDelegate?
    
    private let trackDetailView = TrackDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(trackDetailView)
        trackDetailView.delegate = self
        trackDetailView.trackMovingDelegate = self
        trackDetailView.addedDelegate = self
        setupGesture()
        constraints()
    }
    
    private func constraints() {
        trackDetailView.snp.makeConstraints() { make in
            make.edges.equalToSuperview()
            
        }
    }
    
    func reloadUI(track: SearchCellViewModel.Cell) {
        trackDetailView.playerConfig(track)
    }
    
    func reloadUIAddedTracks(track: AddedTracks) {
        trackDetailView.configAddedTracks(track)
    }
    
    private func setupGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            print("began")
        case .changed:
            let translation = sender.translation(in: view)
            trackDetailView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        case .ended:
            let translation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut) {
                self.trackDetailView.transform = .identity
                if translation.y > 50 {
                    
                    self.delegate?.dismissButton()
                    self.tabBardelegate?.minizeTrackDetail()
                }
            }
        default:
            print("hi")
        }
        
    }
    
}

extension TrackDetailViewController: TrackDetailViewDelegate {
    func sliderUpdate(slider: UISlider, currentTimeLabel: UILabel, remainingTimeLabel: UILabel) {
        delegate?.sliderUpdate(slider: slider, currentTimeLabel: currentTimeLabel, remainingTimeLabel: remainingTimeLabel)
    }
    
    func didChangeTime(slider: UISlider) {
        delegate?.didChangeTime(slider: slider)
    }
    
    func dismissButton() {
        delegate?.dismissButton()
    }
    
    
    func didTapPlayPauseButton() {
        delegate?.didTapPlayPauseButton()
    }
    
    func didChangeVolume(didSlideVolume value: Float) {
        delegate?.didChangeVolume(didSlideVolume: value)
    }
    
}

extension TrackDetailViewController: TrackMovingDelegate {
    func moveBack() -> SearchCellViewModel.Cell? {
        trackMovingDelegate?.moveBack()
    }
    
    func moveForward() -> SearchCellViewModel.Cell? {
        trackMovingDelegate?.moveForward()
        
    }
    
    
}

extension TrackDetailViewController: AddedTrackMovingDelegate {
    func moveBack() -> AddedTracks? {
        addedDelegate?.moveBack()
    }
    
    func moveForward() -> AddedTracks? {
        addedDelegate?.moveForward()
    }
    
    
}



