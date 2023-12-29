//
//  TrackDetailView.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 05.10.2023.
//

import UIKit


protocol TrackDetailViewDelegate: AnyObject {
     
    func didTapPlayPauseButton()
    func didChangeVolume(didSlideVolume value: Float)
    func dismissButton()
    func didChangeTime(slider: UISlider)
    func sliderUpdate(slider: UISlider, currentTimeLabel: UILabel, remainingTimeLabel: UILabel)
}

protocol TrackMovingDelegate: AnyObject {
    func moveBack() -> SearchCellViewModel.Cell?
    func moveForward() -> SearchCellViewModel.Cell?
}

protocol AddedTrackMovingDelegate: AnyObject {
    func moveBack() -> AddedTracks?
    func moveForward() -> AddedTracks?
}


final class TrackDetailView: UIView {
    
    var timer: Timer?
    var cell: SearchCellViewModel.Cell?
    var model: AddedTracks?
    var isPlaying = true

    weak var delegate: TrackDetailViewDelegate?
    weak var trackMovingDelegate: TrackMovingDelegate?
    weak var addedDelegate: AddedTrackMovingDelegate?
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - UI
    
    private let trackImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 16
        image.contentMode = .scaleAspectFit
      //  image.frame = CGRect(x: 0, y: 0, width: 315, height: 315)
        return image
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray5
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "backward.fill",withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemGray5
        slider.maximumTrackTintColor = .darkGray
        slider.value = 0.5
        return slider
    }()
    
    private let minVolumeIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "volume.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        image.tintColor = .white
        return image
    }()
    
    private let maxVolumeIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "volume.3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        image.tintColor = .white
        return image
    }()
    
    private let currerenTimeSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .white
        let configurationSmall = UIImage.SymbolConfiguration(pointSize: 8)
        let configurationLarge = UIImage.SymbolConfiguration(pointSize: 30)
        let largeThumb = UIImage(systemName: "circle.fill", withConfiguration: configurationLarge)
        let smallThumb = UIImage(systemName: "circle.fill", withConfiguration: configurationSmall)
        slider.setThumbImage(smallThumb, for: .normal)
        slider.setThumbImage(largeThumb, for: .highlighted)
        slider.value = 0
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .darkGray
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .systemGray5
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray5
        label.font = .systemFont(ofSize: 13)
        label.text = "--:--"
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "line")
        button.setImage(image, for: .normal)
        return button
    }()
    
    // MARK: - MiniTrack View
    
    private let miniTrackImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 30
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let miniTrackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    private let miniPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let miniForwardButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    let miniTrackView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        view.layer.cornerRadius = 20
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        constraints()
        layer.addSublayer(gradientLayer)
        gradientLayer.zPosition = -1
       
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didChangeVolume), for: .valueChanged)
        currerenTimeSlider.addTarget(self, action: #selector(didChangeTime), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        miniPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        miniForwardButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
       // animateText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        //animateText()
    }
    

    
    @objc private func didTapBack() {
        trackMovingDelegate?.moveBack()
        addedDelegate?.moveBack()
    }
    
    @objc private func didTapPlayPause() {
        isPlaying = !isPlaying
        delegate?.didTapPlayPauseButton()
        let playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        playPauseButton.setImage(!isPlaying ? playImage : pauseImage, for: .normal)
        !isPlaying ? reduceImage() : enlargeImage()
        
    }
    
    @objc private func didTapNext()  {
        trackMovingDelegate?.moveForward()
        addedDelegate?.moveForward()
    }
    
    @objc private func dismiss() {
        delegate?.dismissButton()
    }
    
    @objc private func didChangeVolume() {
        delegate?.didChangeVolume(didSlideVolume: volumeSlider.value)
    }
    
    @objc private func didChangeTime() {
        delegate?.didChangeTime(slider: currerenTimeSlider)
    }
    
    @objc private func updateSlider() {
        delegate?.sliderUpdate(slider: currerenTimeSlider, currentTimeLabel: currentTimeLabel, remainingTimeLabel: remainingTimeLabel)
    }
    
    // MARK: - Setup View
    
    func setupView() {
        addSubview(trackImageView)
        addSubview(trackNameLabel)
        addSubview(artistNameLabel)
        addSubview(backButton)
        addSubview(forwardButton)
        addSubview(playPauseButton)
        addSubview(volumeSlider)
        addSubview(minVolumeIcon)
        addSubview(maxVolumeIcon)
        addSubview(currerenTimeSlider)
        addSubview(currentTimeLabel)
        addSubview(remainingTimeLabel)
        addSubview(dismissButton)
        addSubview(miniTrackView)
        miniTrackView.addSubview(miniTrackImageView)
        miniTrackView.addSubview(miniTrackNameLabel)
        miniTrackView.addSubview(miniPauseButton)
        miniTrackView.addSubview(miniForwardButton)
    }
    
    // MARK: - Constraints
    
    func constraints() {
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            //make.top.equalTo(safeAreaInsets.top).offset(40)
            make.centerX.equalToSuperview()
        }
        
        trackImageView.snp.makeConstraints { make in
            //make.left.right.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.top.equalTo(dismissButton).offset(100)
          //  make.top.equalToSuperview().offset(-15)
            //make.height.equalTo(350)
            make.width.equalTo(350)
            make.height.equalTo(350)
        }
        
        trackNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(trackImageView.snp.bottom).offset(20)
           // make.center.equalToSuperview().offset(70)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(trackNameLabel.snp.bottom).offset(5)
        }
        
        currerenTimeSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(artistNameLabel.snp.bottom).offset(25)
            //make.top.equalToSuperview().offset(200)
            make.width.equalToSuperview().multipliedBy(0.9)
            
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(currerenTimeSlider.snp.bottom).offset(10)
            
        }
        
        remainingTimeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(currerenTimeSlider.snp.bottom).offset(10)
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(70)
            make.top.equalTo(currerenTimeSlider.snp.bottom).offset(80)
            
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(currerenTimeSlider.snp.bottom).offset(75)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(70)
            make.top.equalTo(currerenTimeSlider.snp.bottom).offset(80)
        }
        
        minVolumeIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
           // make.bottom.equalToSuperview().inset(105)
            make.top.equalTo(backButton.snp.bottom).offset(70)
        }
        
        maxVolumeIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
           // make.bottom.equalToSuperview().inset(105)
            make.top.equalTo(forwardButton.snp.bottom).offset(70)
        }
        
        volumeSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(50)
            //make.bottom.equalToSuperview().inset(100)
           // make.bottom.equalTo(playPauseButton).offset(75)
            make.top.equalTo(playPauseButton.snp.bottom).offset(63)
            make.width.equalToSuperview().multipliedBy(0.7)
            
        }
        
        miniTrackView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalTo(400)
        }
        
        miniTrackImageView.snp.makeConstraints { make in
            make.top.equalTo(miniTrackView).offset(5)
            make.left.equalTo(miniTrackView).offset(5)
            make.bottom.equalTo(miniTrackView).offset(-5)
            make.width.equalTo(90)
            
        }
        
        miniTrackNameLabel.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.left.equalTo(miniTrackImageView).inset(90)
            make.top.equalTo(miniTrackImageView).offset(20)
        }
        
        miniPauseButton.snp.makeConstraints { make in
            make.right.equalTo(miniTrackNameLabel).offset(75)
            make.top.equalTo(miniTrackView).offset(20)
        }
        
        miniForwardButton.snp.makeConstraints { make in
            make.right.equalTo(miniPauseButton).offset(65)
            make.top.equalTo(miniTrackView).offset(20)
        }
        
    }
    
    // MARK: - Player Config
    
    private func setImage(urlString: String?) {
        
        if let urlString = urlString {
            NetworkRequest.shared.request(urlString: urlString) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data)?.withRenderingMode(.alwaysOriginal) else { return }
                    self?.trackImageView.tintColor = .gray
                    self?.trackImageView.image = image
                    self?.miniTrackImageView.image = image
                    self?.configBackground(image)
                    
                case .failure(let error):
                    self?.trackImageView.image = UIImage(systemName: "questionmark")
                    print("No album logo:", error.localizedDescription)
                    
                }
                
            }
        } else {
            trackImageView.image = UIImage(systemName: "questionmark")
            
        }
    }
    
    func playerConfig(_ viewModel: SearchCellViewModel.Cell) {
        self.cell = viewModel
        miniTrackNameLabel.text = viewModel.trackName
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        guard let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600") else { return }
        setImage(urlString: string600)
        trackImageView.image = UIImage(named: string600)
        miniTrackImageView.image = UIImage(named: string600)
        let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40)))

        playPauseButton.setImage(pauseImage, for: .normal)
        currerenTimeSlider.value = 0
        enlargeImage()
        isPlaying = true
    }
    
    func configAddedTracks(_ viewModel: AddedTracks) {
        self.model = viewModel
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        guard let string600 = viewModel.trackImage?.replacingOccurrences(of: "100x100", with: "600x600") else { return }
        setImage(urlString: string600)
        trackImageView.image = UIImage(named: string600)
        let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        playPauseButton.setImage(pauseImage, for: .normal)
        currerenTimeSlider.value = 0
        enlargeImage()
        isPlaying = true
        
    }
    
    // MARK: - TrackImage animations
    
   private func enlargeImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            self?.trackImageView.transform = .identity
        }
        
    }
    
   private func reduceImage() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            let scale: CGFloat = 0.7
            self?.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
       
    }
    
    private func animateText() {
        
        
            
        if trackNameLabel.text?.count ?? 0 > 30, isPlaying == false {
            //self.layoutIfNeeded()
            let labelMid = self.trackNameLabel.frame.midX
            let labelLHS = self.trackNameLabel.frame.minX - self.trackNameLabel.frame.width
            let labelRHS = (self.trackNameLabel.frame.maxX) + (self.trackNameLabel.frame.width)
            let labelAnimate = CABasicAnimation(keyPath: "position.x")
            
            
            labelAnimate.fromValue = NSNumber(value: labelMid)
            labelAnimate.toValue = NSNumber(value: labelLHS)
            labelAnimate.beginTime = 3
            labelAnimate.duration = 10
            
            let labelAnimate1 = CABasicAnimation(keyPath: "position.x")
            labelAnimate1.fromValue =  NSNumber(value: labelRHS)
            labelAnimate1.toValue =  NSNumber(value: labelLHS)
            labelAnimate1.beginTime = 10
            labelAnimate1.duration = 20
            
            let group = CAAnimationGroup()
            group.animations = [labelAnimate, labelAnimate1]
            group.duration = 20
            group.repeatCount = .zero
            group.beginTime = 0
            self.trackNameLabel.layer.add(group, forKey: "basic")
            
            
        }
        
    }
    // MARK: - Background Color Config
    
    private func configBackground(_ image: UIImage) {
        let images = image.split2Images()
        
        if let imgTopColor = images[0].averageColor?.cgColor, let imgBottomColor = images[1].averageColor?.cgColor {
            gradientLayer.colors = [
                imgTopColor, imgBottomColor
            ]
        }
    }
    }
        
    
    
