//
//  Tooltip.swift
//  UIComponentsFramework
//
//  Created by Aviata on 21.06.2022.
//

import Foundation
import UIKit

public class Tooltip: UIView {
    
    enum Constants {
        enum Default {
            static let topPadding: CGFloat = 9
            static let bottomPadding: CGFloat = 16
            static let messageLabelSidePadding: CGFloat = 16
        }
        enum Color {
            static let monoBlackMain = UIColor(red: 56, green: 56, blue: 56, alpha: 1)
        }
        static let animationDuration = 0.4
    }
    
    enum Duration: Double {
        case SHORT_ONE_HALF = 1.5
        case SHORT_TWO_SEC = 2
        case SHORT = 3
        case LONG = 6
    }
    
    struct Configuration {
        let text: String
        let additionalText: NSAttributedString
        let sideInset: CGFloat = 32.0
        let textSideInset: CGFloat = 12
        let yPosition: CGFloat
        var tooltipDuration: Duration = .LONG
    }
    var callback: (() -> ())?
    private var removalTimer: Timer?
    private let configuration: Configuration

    private let containerView = UIView()
    private let bottomTriangleView = UIView()
    private let textLabel = UILabel()
    private let additionalLabel = UILabel()
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Tooltip {
    
    private func setup() {
        setupView()
        addSubviews()
        setupLayout()
        drawTriangle()
        setupGestures()
    }
    
    private func setupView() {
        containerView.backgroundColor = Constants.Color.monoBlackMain
        containerView.layer.cornerRadius = 8
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = .white
        additionalLabel.isUserInteractionEnabled = true
    }
    
    private func addSubviews() {
        [containerView, bottomTriangleView].forEach { addSubview($0) }
        [textLabel, additionalLabel].forEach { containerView.addSubview($0) }
    }
    
    private func setupLayout() {
        setupConstraintsContainerView()
        setupConstraintsBottomTriangleView()
        setupConstraintsTextLabel()
        setupConstraintsAdditionalLabel()
    }
    
    private func setupConstraintsContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView.superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView.superview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView.superview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        addConstraints([topConstraint, trailingConstraint, leadingConstraint])
    }
    
    private func setupConstraintsBottomTriangleView() {
        bottomTriangleView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: bottomTriangleView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: bottomTriangleView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomTriangleView.superview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let centerXConstraint = NSLayoutConstraint(item: bottomTriangleView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bottomTriangleView.superview, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: bottomTriangleView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
        let heightConstraint = NSLayoutConstraint(item: bottomTriangleView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 16)
        addConstraints([topConstraint, bottomConstraint, centerXConstraint, widthConstraint, heightConstraint])
    }
    
    private func setupConstraintsTextLabel() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: Constants.Default.topPadding)
        let leadingConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: configuration.textSideInset)
        let trailingConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -configuration.textSideInset)
        addConstraints([topConstraint, leadingConstraint, trailingConstraint])
    }
    
    private func setupConstraintsAdditionalLabel() {
        additionalLabel.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: additionalLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: textLabel, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: Constants.Default.topPadding)
        let leadingConstraint = NSLayoutConstraint(item: additionalLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: configuration.textSideInset)
        let trailingConstraint = NSLayoutConstraint(item: additionalLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -configuration.textSideInset)
        let bottomConstraint = NSLayoutConstraint(item: additionalLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -Constants.Default.bottomPadding)
        addConstraints([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    private func drawTriangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 10))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = Constants.Color.monoBlackMain.cgColor
        bottomTriangleView.layer.addSublayer(shapeLayer)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedAdditionalLabel))
        additionalLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tappedAdditionalLabel() {
        callback?()
    }
}

extension Tooltip {
    
    static func dismissTooltip() {
        UIApplication.shared.keyWindow?.subviews.forEach {
            if $0 is Tooltip {
                $0.removeFromSuperview()
            }
        }
    }
    
    func show() {
        textLabel.text = configuration.text
        additionalLabel.attributedText = configuration.additionalText
        showTooltip(configuration.yPosition)
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 1
        }, completion: { _ in
            self.removalTimer = Timer.scheduledTimer(timeInterval: self.configuration.tooltipDuration.rawValue, target: self, selector: #selector(self.removePreviousTooltip), userInfo: nil, repeats: false)
        })
    }
    
    private func showTooltip(_ yPosition: CGFloat) {
        UIApplication.shared.keyWindow?.addSubview(self)
        let heightPadding = (Constants.Default.topPadding * 2) + Constants.Default.bottomPadding
        let viewSize = CGSize(width: UIScreen.main.bounds.width - (configuration.sideInset * 2) - (configuration.textSideInset * 2), height: UIScreen.main.bounds.height * 0.8)
        let textLabelHeight = textLabel.sizeThatFits(viewSize).height
        let additionalLabelHeight = additionalLabel.sizeThatFits(viewSize).height
        let bottomTriangleViewHeight = 14.0
        let fullHeight = heightPadding + textLabelHeight + additionalLabelHeight + bottomTriangleViewHeight
        
        frame = CGRect(x: configuration.sideInset, y: yPosition - fullHeight, width: UIScreen.main.bounds.width - configuration.sideInset * 2, height: fullHeight)
        
        alpha = 0.0
    }
    
    @objc private func removePreviousTooltip() {
        removalTimer?.invalidate()
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
