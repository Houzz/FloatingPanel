//
//  Created by Shin Yamamoto on 2018/09/18.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit

protocol LayoutGuideProvider {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}
extension UILayoutGuide: LayoutGuideProvider {}

class CustomLayoutGuide: LayoutGuideProvider {
    let topAnchor: NSLayoutYAxisAnchor
    let bottomAnchor: NSLayoutYAxisAnchor
    init(topAnchor: NSLayoutYAxisAnchor, bottomAnchor: NSLayoutYAxisAnchor) {
        self.topAnchor = topAnchor
        self.bottomAnchor = bottomAnchor
    }
}

extension UIViewController {
    var layoutInsets: UIEdgeInsets {
        view.safeAreaInsets
    }

    var layoutGuide: LayoutGuideProvider {
        view!.safeAreaLayoutGuide
    }
}

protocol SideLayoutGuideProvider {
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: SideLayoutGuideProvider {}
extension UILayoutGuide: SideLayoutGuideProvider {}

// The reason why UIView has no extensions of safe area insets and top/bottom guides
// is for iOS10 compat.
extension UIView {
    var sideLayoutGuide: SideLayoutGuideProvider {
        safeAreaLayoutGuide
    }
}

extension UIView {
    func disableAutoLayout() {
        let frame = self.frame
        translatesAutoresizingMaskIntoConstraints = true
        self.frame = frame
    }
    func enableAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}


extension UIGestureRecognizer.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .began: return "Began"
        case .changed: return "Changed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        case .ended: return "Endeded"
        case .possible: return "Possible"
        @unknown default:
            return "Unknown"
        }
    }
}

extension UIScrollView {
    public var contentOffsetZero: CGPoint {
        return CGPoint(x: 0.0, y: 0.0 - contentInset.top)
    }
}

extension UISpringTimingParameters {
    public convenience init(dampingRatio: CGFloat, frequencyResponse: CGFloat, initialVelocity: CGVector = .zero) {
        let mass = 1 as CGFloat
        let stiffness = pow(2 * .pi / frequencyResponse, 2) * mass
        let damp = 4 * .pi * dampingRatio * mass / frequencyResponse
        self.init(mass: mass, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}
