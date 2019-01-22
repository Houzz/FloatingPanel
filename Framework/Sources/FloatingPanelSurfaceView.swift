//
//  Created by Shin Yamamoto on 2018/09/26.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit

class FloatingPanelSurfaceContentView: UIView {}

/// A view that presents a surface interface in a floating panel.
public class FloatingPanelSurfaceView: UIView {
    
    /// A GrabberHandleView object displayed at the top of the surface view.
    ///
    /// To use a custom grabber handle, hide this and then add the custom one
    /// to the surface view at appropirate coordinates.
    public var grabberHandle: GrabberHandleView!
    
    /// The height of the grabber bar area
    public static var topGrabberBarHeight: CGFloat {
        return Default.grabberTopPadding * 2 + GrabberHandleView.Default.height // 17.0
    }
    
    /// A root view of a content view controller
    public var contentView: UIView!
    public var contentViewContainer: UIView!
    
    private var color: UIColor? = .white { didSet { setNeedsLayout() } }
    var bottomOverflow: CGFloat = 0.0 {
        didSet {
            containedBottomBC?.constant = -bottomOverflow
            contentBottomBC?.constant = bottomOverflow
        }
    }// Must not call setNeedsLayout()
    
    public override var backgroundColor: UIColor? {
        get { return color }
        set { color = newValue }
    }
    
    /// The radius to use when drawing top rounded corners.
    ///
    /// `self.contentView` is masked with the top rounded corners automatically on iOS 11 and later.
    /// On iOS 10, they are not automatically masked because of a UIVisualEffectView issue. See https://forums.developer.apple.com/thread/50854
    public var panelCornerRadius: CGFloat = 0.0 {
        didSet
        {
            contentViewContainer.layer.cornerRadius = panelCornerRadius
            setNeedsLayout()
        }
    }
    
    /// A Boolean indicating whether the surface shadow is displayed.
    public var shadowHidden: Bool = false  { didSet { setNeedsLayout() } }
    
    /// The color of the surface shadow.
    public var panelShadowColor: UIColor = .black  { didSet { setNeedsLayout() } }
    
    /// The offset (in points) of the surface shadow.
    public var panelShadowOffset: CGSize = CGSize(width: 0.0, height: 1.0)  { didSet { setNeedsLayout() } }
    
    /// The opacity of the surface shadow.
    public var panelShadowOpacity: Float = 0.2 { didSet { setNeedsLayout() } }
    
    /// The blur radius (in points) used to render the surface shadow.
    public var panelShadowRadius: CGFloat = 3  { didSet { setNeedsLayout() } }
    
    /// The width of the surface border.
    public var panelBorderColor: UIColor?  { didSet { setNeedsLayout() } }
    
    /// The color of the surface border.
    public var panelBorderWidth: CGFloat = 0.0  { didSet { setNeedsLayout() } }
    
    private var containedBottomBC: NSLayoutConstraint?
    private var contentBottomBC: NSLayoutConstraint?
    
    private struct Default {
        public static let grabberTopPadding: CGFloat = 6.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    private func render() {
        super.backgroundColor = .clear
        self.clipsToBounds = false
        
        let contentViewContainer = UIView()
        addSubview(contentViewContainer)
        self.contentViewContainer = contentViewContainer
        
        let contentView = FloatingPanelSurfaceContentView()
        contentView.clipsToBounds = false
        contentViewContainer.addSubview(contentView)
        contentViewContainer.clipsToBounds = true
        self.contentView = contentView as UIView
        
        contentViewContainer.backgroundColor = color
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewContainer.clipsToBounds = true
        contentViewContainer.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            contentViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        contentViewContainer.layer.cornerRadius = panelCornerRadius
        
        contentBottomBC = contentViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        containedBottomBC = contentView.bottomAnchor.constraint(equalTo: contentViewContainer.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            contentViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            contentViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            contentViewContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            contentBottomBC!,
            
            contentView.topAnchor.constraint(equalTo: contentViewContainer.topAnchor, constant: 0.0),
            contentView.leftAnchor.constraint(equalTo: contentViewContainer.leftAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: contentViewContainer.rightAnchor, constant: 0.0),
            containedBottomBC!
            ])
        
        let grabberHandle = GrabberHandleView()
        addSubview(grabberHandle)
        self.grabberHandle = grabberHandle
        
        grabberHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberHandle.topAnchor.constraint(equalTo: topAnchor, constant: Default.grabberTopPadding),
            grabberHandle.widthAnchor.constraint(equalToConstant: grabberHandle.frame.width),
            grabberHandle.heightAnchor.constraint(equalToConstant: grabberHandle.frame.height),
            grabberHandle.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
//        log.debug("SurfaceView frame", frame)
        
        updateLayers()
        
        contentView?.layer.borderColor = borderColor?.cgColor
        contentView?.layer.borderWidth = borderWidth
        contentView?.frame = bounds
    }
    
    private func updateLayers() {
//        log.debug("SurfaceView bounds", bounds)
        
        if shadowHidden == false {
            layer.shadowColor = panelShadowColor.cgColor
            layer.shadowOffset = panelShadowOffset
            layer.shadowOpacity = panelShadowOpacity
            layer.shadowRadius = panelShadowRadius
        }
    }
    
    func add(contentView: UIView) {
        let childView = contentView
        self.contentView.addSubview(childView)
        
        childView.clipsToBounds = false
        childView.frame = contentView.bounds
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
            childView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0.0),
            childView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0.0),
            childView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
            ])
    }
}
