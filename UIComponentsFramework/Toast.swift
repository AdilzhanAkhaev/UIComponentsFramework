//
//  Toast.swift
//  UIComponentsFramework
//
//  Created by Aviata on 21.06.2022.
//

import Foundation
import UIKit

public class Toast: UIView {
    
    private var removalTimer: Timer?
    private let configuration: ToastConfiguration
    
    private struct Constant {
        static let defaultVerticalPadding: CGFloat = 16
        static let animationDuration = 0.4
        static let messageLabelSidePadding: CGFloat = 16
        enum Color {
            static let monoBlackMain = UIColor(red: 56, green: 56, blue: 56, alpha: 1)
        }
    }
    
    struct ToastConfiguration {
        let text: String
        let textSize: CGFloat = 16.0
        let bottomInset: CGFloat
        var toastDuration: ToastDuration = .LONG
    }
    
    enum ToastDuration: Double {
        case SHORT_ONE_HALF = 1.5
        case SHORT_TWO_SEC = 2
        case SHORT = 3
        case LONG = 6
    }
    
    enum ToastBottomInset {
        case withTabBar
        case withoutTabBar
        case withBottomBar
        case custom(bottomInset: CGFloat)
        
        var value: CGFloat {
            switch self {
            case .withTabBar:
                return 60
            case .withoutTabBar:
                return 32
            case .withBottomBar:
                return 85
            case .custom(let bottomInset):
                return bottomInset
            }
        }
    }
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    var sideInset: CGFloat {
        return 16
    }
    
    init(configuration: ToastConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setup()
    }
    
    func show() {
        messageLabel.text = configuration.text
        showToast(configuration.bottomInset)
        UIView.animate(withDuration: Constant.animationDuration, animations: {
            self.alpha = 1
        }, completion: { _ in
            self.removalTimer = Timer.scheduledTimer(timeInterval: self.configuration.toastDuration.rawValue, target: self, selector: #selector(self.removePreviousToast), userInfo: nil, repeats: false)
        })
    }
    
    private func showToast(_ bottomInset: CGFloat) {
        UIApplication.shared.keyWindow?.addSubview(self)
        
        let calculatedSize = messageLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - sideInset * 2 - Constant.messageLabelSidePadding * 2, height: UIScreen.main.bounds.height * 0.8))
        
        let fullHeight = calculatedSize.height + Constant.defaultVerticalPadding
        
        frame = CGRect(x: sideInset, y: UIScreen.main.bounds.height - getBottomInset(bottomInset) - fullHeight, width: UIScreen.main.bounds.width - sideInset * 2, height: fullHeight)
        
        alpha = 0.0
    }
    
    private func getBottomInset(_ inset: CGFloat) -> CGFloat {
        if #available(iOS 11.0, *) {
            return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + inset
        }
        return inset
    }
    
    static func dismissToast() {
        UIApplication.shared.keyWindow?.subviews.forEach {
            if $0 is Toast {
                $0.removeFromSuperview()
            }
        }
    }
    
    @objc private func removePreviousToast() {
        removalTimer?.invalidate()
        UIView.animate(withDuration: Constant.animationDuration, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    private func setup() {
        setupLook()
        addSubviews()
    }
    
    private func setupLook() {
        backgroundColor = Constant.Color.monoBlackMain
        layer.cornerRadius = 8
        layer.opacity = 0.95
    }
    
    private func addSubviews() {
        addSubview(messageLabel)
        setupConstraintsMessageLabel()
    }
    
    private func setupConstraintsMessageLabel() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: messageLabel.superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 8)
        let leadingConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: messageLabel.superview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: Constant.messageLabelSidePadding)
        let trailingConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: messageLabel.superview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -Constant.messageLabelSidePadding)
        let bottomConstraint = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: messageLabel.superview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -8)
        addConstraints([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unimplemented")
    }
}
