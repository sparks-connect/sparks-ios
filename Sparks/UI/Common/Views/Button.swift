//
//  Button.swift
//  BehaviorPro
//
//  Created by Irakli Vashakidze on 1/28/19.
//  Copyright © 2019 BehaviorPro. All rights reserved.
//

import UIKit
import SnapKit

enum LoadingButtonStyle {
    case borderWidth
    case borderColor
    case backgroundColor
    case image
    case backgroundImage
    case text
    case tintColor
}

@objc class Button: UIButton {
    
    private var key : String?
    var args: [Any]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translate()
    }
    
    func configure(){
        //        self.tintColor = .white
        //        self.setTitleColor(self.tintColor, for: .normal)
        //        self.setTitleColor(Color.lightGray.uiColor, for: .disabled)
        //        self.translate()
    }
    
    private func translate() {
        //        self.setTitle(self.title(for: .normal)?.localized, for: .normal)
        //        self.setTitle(self.title(for: .disabled)?.localized, for: .disabled)
    }
    
    @IBInspectable var title: String! {
        didSet {
            self.setTitle(title, for: .normal)
        }
    }
}

class LoadingButton: Button {
    
    fileprivate var indicator = UIActivityIndicatorView()
    private lazy var styles = [LoadingButtonStyle : [UIButton.State.RawValue : Any]]()
    
    final var cornerRadius: CGFloat! = 4 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    final var loadingText: String?
    private final var originalTitle: String?
    private final var previousImage: UIImage?
    private final var previousBackgroundImage: UIImage?
    
    @IBInspectable var movesTextToLeftWhileLoading: Bool = true
    
    var activityIndicatorVisible : Bool = true {
        didSet {
            indicator.isHidden = !activityIndicatorVisible
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.updateEnabledState()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.updateEnabledState()
        }
    }
    
    override func configure() {
        super.configure()
        self.addSubview(self.indicator)
        self.indicator.hidesWhenStopped = true
        self.setTintColor(UIColor.white, forState: .normal)
        self.setTintColor(Color.lightGray.uiColor, forState: .disabled)
        self.movesTextToLeftWhileLoading = false
        self.setBackgroundColor(Color.primary.uiColor, forState: .normal)
        self.setBackgroundColor(UIColor.clear, forState: .disabled)
        self.setBorderColor(UIColor.white, forState: .normal)
        self.setBorderColor(Color.lightGray.uiColor, forState: .disabled)
        self.setBorderWidth(1, forState: .normal)
        self.setBorderWidth(1, forState: .disabled)
    }
    
    func setBackgroundColor(_ color: UIColor, forState state: UIButton.State) {
        if self.styles[.backgroundColor] == nil {
            self.styles[.backgroundColor] = [UIButton.State.RawValue : Any]()
        }
        self.styles[.backgroundColor]?[state.rawValue] = color
        self.updateEnabledState()
    }
    
    func setBorderWidth(_ width: CGFloat, forState state: UIButton.State) {
        if self.styles[.borderWidth] == nil {
            self.styles[.borderWidth] = [UIButton.State.RawValue : Any]()
        }
        self.styles[.borderWidth]?[state.rawValue] = width
        self.updateEnabledState()
    }
    
    func setBorderColor(_ color: UIColor, forState state: UIButton.State) {
        if self.styles[.borderColor] == nil {
            self.styles[.borderColor] = [UIButton.State.RawValue : Any]()
        }
        self.styles[.borderColor]?[state.rawValue] = color
        self.updateEnabledState()
    }
    
    func setTintColor(_ color: UIColor, forState state: UIButton.State) {
        if self.styles[.tintColor] == nil {
            self.styles[.tintColor] = [UIButton.State.RawValue : Any]()
        }
        self.styles[.tintColor]?[state.rawValue] = color
        self.updateEnabledState()
    }
    
    private func backgroundColor(for state: UIButton.State) -> UIColor? {
        return self.styles[.backgroundColor]?[state.rawValue] as? UIColor
    }
    
    private func borderColor(for state: UIButton.State) -> UIColor? {
        return self.styles[.borderColor]?[state.rawValue] as? UIColor
    }
    
    private func borderWidth(for state: UIButton.State) -> CGFloat {
        return self.styles[.borderWidth]?[state.rawValue] as? CGFloat ?? 0
    }
    
    private func tintColor(for state: UIButton.State) -> UIColor? {
        return self.styles[.tintColor]?[state.rawValue] as? UIColor
    }
    
    func updateEnabledState() {
        let state: UIButton.State = self.state
        self.backgroundColor = self.backgroundColor(for: state)
        self.tintColor = self.tintColor(for: state)
        self.setTitleColor(self.tintColor, for: state)
        self.indicator.color = self.tintColor
        self.layer.borderColor = self.borderColor(for: state)?.cgColor
        self.layer.borderWidth = self.borderWidth(for: state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.bounds.size
        let w = size.width * 0.8
        let m = (size.height - w)/2
        self.indicator.frame = CGRect(x: size.width - (m + w), y: m, width: w, height: w)
    }
    
    func startAnimatingLoader() {
        self.isEnabled = false
        self.previousImage = self.currentImage
        self.previousBackgroundImage = self.currentBackgroundImage
        self.setBackgroundImage(nil, for: .normal)
        self.setImage(nil, for: .normal)
        if movesTextToLeftWhileLoading {
            self.contentHorizontalAlignment = .left
            self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        
        if let title = self.loadingText {
            self.originalTitle = self.title(for: .normal)
            self.setTitle(title, for: .normal)
        }
        if activityIndicatorVisible != false {
                self.indicator.startAnimating()
        }
    }
    
    func stopAnimatingLoader() {
        self.isEnabled = true
        self.setBackgroundImage(self.previousBackgroundImage, for: .normal)
        self.setImage(self.previousImage, for: .normal)
        self.contentHorizontalAlignment = .center
        self.contentEdgeInsets = UIEdgeInsets.zero
        self.indicator.stopAnimating()
        
        if let title = self.originalTitle {
            self.setTitle(title, for: .normal)
        }
    }
}

class CircleLoadingButton : LoadingButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}

class CircleButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height / 2
    }
}


class ArrowButton : Button {
    
    private(set) var imageLabel : ImageLabel!
    
    private lazy var arrowImg : UIImageView = {
        let arrowImg = UIImageView()
        arrowImg.image = #imageLiteral(resourceName: "arrowIcon")
        return arrowImg
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        configure()
    }
    
    override func configure() {
        super.configure()
        layer.cornerRadius = 15
        clipsToBounds = true
    }
    
    convenience init(image : UIImage? = nil, labelText : String){
        self.init(frame : .zero)
        imageLabel = ImageLabel(image: image, label: labelText)
        layout()
    }
    
    func setTitleColor(_ color: UIColor) {
        self.imageLabel.setTextColor(color)
    }
    
    func setImage(_ image: UIImage?){
        arrowImg.image = image
    }
    
    func setText(_ title: String) {
        imageLabel.setText(title)
    }
    
    func setFont(_ font: UIFont) {
        self.titleLabel?.font = font
        self.imageLabel.setTextFont(font)
    }
    
    func layout(){
        self.addSubview(arrowImg)
        arrowImg.snp.makeConstraints {
            $0.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubview(imageLabel)
        imageLabel.snp.makeConstraints{
            $0.left.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class ActionButton: LoadingButton {
    
    override func configure() {
        super.configure()
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderWidth = 1
        titleLabel?.font = Font.medium.uiFont(ofSize: 14)
        setTitleColor(Color.inkBlue.uiColor, for: .normal)
        setTitleColor(Color.red.uiColor, for: .selected)
        
        configureState()
    }
    
    override var isSelected: Bool {
        didSet {
            configureState()
        }
    }
    
    private func configureState() {
        layer.borderColor = isSelected ? Color.red.uiColor.cgColor : Color.lightGray2.uiColor.cgColor
    }
}

class GenderButton: BaseView {
    
    var isSelected: Bool = false {
        didSet {
            configureState()
        }
    }
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.medium.uiFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override func configure() {
        super.configure()
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderWidth = 0
        
        addSubviewWithConstrainedBounds(subview: titleLabel)
        
        configureState()
    }
    
    func configureState() {
        backgroundColor = isSelected ? Color.purple.uiColor : Color.fadedBackground.uiColor
        titleLabel.textColor = isSelected ? .white : Color.lightPurple.uiColor
    }
}

class PrimaryButton: LoadingButton {
    override func configure() {
        super.configure()
        self.setTitleColor(.white, for: .normal)
        self.setBackgroundColor(Color.purple.uiColor, forState: .normal)
        self.setBackgroundColor(.clear, forState: .disabled)
        self.setBorderColor(UIColor.white, forState: .disabled)
        self.setBorderWidth(1, forState: .disabled)
        self.setBorderWidth(0, forState: .normal)
        self.layer.cornerRadius = 16
        self.titleLabel?.font = UIFont.font(for: 14, style: .regular)
    }
}
