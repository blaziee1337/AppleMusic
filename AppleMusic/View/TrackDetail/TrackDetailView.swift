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
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 50)))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let trackImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 16
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.frame = CGRect(x: 0, y: 0, width: 500, height: 0)
       // label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray4
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private let backwardButton: UIButton = {
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
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40)))
        button.setImage(image, for: .normal)
        return button
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
        slider.maximumTrackTintColor = .systemGray
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
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemGray5
        slider.maximumTrackTintColor = .systemGray
        slider.value = 0.5
        return slider
    }()
    
    private let minVolumeIcon: UIImageView = {
        let image = UIImageView()
        let configurationSmall = UIImage.SymbolConfiguration(pointSize: 10)
        image.image = UIImage(systemName: "volume.fill", withConfiguration: configurationSmall)
        image.tintColor = .white
        return image
    }()
    
    private let maxVolumeIcon: UIImageView = {
        let image = UIImageView()
        let configurationSmall = UIImage.SymbolConfiguration(pointSize: 10)
        image.image = UIImage(systemName: "volume.3.fill", withConfiguration: configurationSmall)
        image.tintColor = .white
        return image
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 25
        return stackView
    }()
    
    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    private let timeLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 1
        return stackView
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let volumeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 11
        return stackView
    }()
    
   //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        constraints()
        setupStackView()
        layer.addSublayer(gradientLayer)
        gradientLayer.zPosition = -1
       
        backwardButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didChangeVolume), for: .valueChanged)
        currerenTimeSlider.addTarget(self, action: #selector(didChangeTime), for: .valueChanged)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        animateText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        animateText()
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
    
    private func setupView() {
        addSubview(trackImageView)
        addSubview(trackNameLabel)
        addSubview(artistNameLabel)
        addSubview(backwardButton)
        addSubview(forwardButton)
        addSubview(playPauseButton)
        addSubview(volumeSlider)
        addSubview(minVolumeIcon)
        addSubview(maxVolumeIcon)
        addSubview(currerenTimeSlider)
        addSubview(currentTimeLabel)
        addSubview(remainingTimeLabel)
        addSubview(dismissButton)
        addSubview(mainStackView)
        addSubview(labelsStackView)
        addSubview(buttonsStackView)
        addSubview(verticalStackView)
        addSubview(volumeStackView)
    }
    
    // MARK: - Setup StackView
    
    private func setupStackView() {
        mainStackView.addArrangedSubview(dismissButton)
        mainStackView.addArrangedSubview(trackImageView)
        mainStackView.addArrangedSubview(labelsStackView)
        mainStackView.addArrangedSubview(verticalStackView)
        mainStackView.addArrangedSubview(buttonsStackView)
        mainStackView.addArrangedSubview(volumeStackView)
        
        labelsStackView.addArrangedSubview(trackNameLabel)
        labelsStackView.addArrangedSubview(artistNameLabel)
        
        buttonsStackView.addArrangedSubview(backwardButton)
        buttonsStackView.addArrangedSubview(playPauseButton)
        buttonsStackView.addArrangedSubview(forwardButton)
        
        timeLabelsStackView.addArrangedSubview(currentTimeLabel)
        timeLabelsStackView.addArrangedSubview(remainingTimeLabel)
            
        verticalStackView.addArrangedSubview(currerenTimeSlider)
        verticalStackView.addArrangedSubview(timeLabelsStackView)
        

        volumeStackView.addArrangedSubview(minVolumeIcon)
        volumeStackView.addArrangedSubview(volumeSlider)
        volumeStackView.addArrangedSubview(maxVolumeIcon)
    }
    
    // MARK: - Constraints
    
    func constraints() {
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-30)
            
        }
        
        trackImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(trackImageView.snp.width)
        }
        
        minVolumeIcon.snp.makeConstraints { make in
            make.height.equalTo(17)
        }
        
        maxVolumeIcon.snp.makeConstraints { make in
            make.height.equalTo(17)
        }
    }
    
    // MARK: - Player Config
    
    private func setImage(urlString: String?) {
        
        if let urlString = urlString {
            NetworkRequest.shared.request(urlString: urlString) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else { return }
                    self?.trackImageView.image = image
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
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        guard let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600") else { return }
        setImage(urlString: string600)
        trackImageView.image = UIImage(named: string600)
        let pauseImage = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40)))

        playPauseButton.setImage(pauseImage, for: .normal)
        currerenTimeSlider.value = 0
        enlargeImage()
        isPlaying = true
        animateText()
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
        animateText()
        
    }
    
    // MARK: - Animations
    
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
    
        if trackNameLabel.text?.count ?? 0 > 25 {
            
            layoutIfNeeded()
            let labelMid = trackNameLabel.frame.midX
            let labelLHS = trackNameLabel.frame.minX - trackNameLabel.frame.width
            let labelRHS = (trackNameLabel.frame.maxX) + (trackNameLabel.frame.width)
            let labelAnimate = CABasicAnimation(keyPath: "position.x")
            
            labelAnimate.fromValue = labelMid
            labelAnimate.toValue = labelLHS
            labelAnimate.beginTime = 3
            labelAnimate.duration = 10
            
            let labelAnimate1 = CABasicAnimation(keyPath: "position.x")
            labelAnimate1.fromValue =  labelRHS
            labelAnimate1.toValue =  labelLHS
            labelAnimate1.beginTime = 10
            labelAnimate1.duration = 20
            
            let group = CAAnimationGroup()
            group.animations = [labelAnimate, labelAnimate1]
            group.duration = 20
            group.repeatCount = .greatestFiniteMagnitude
            group.beginTime = 0
            trackNameLabel.layer.add(group, forKey: "basic")
                
            
            } else {
                trackNameLabel.layer.removeAllAnimations()
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
        
    
    
