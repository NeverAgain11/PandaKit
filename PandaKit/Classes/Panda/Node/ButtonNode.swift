//
//  ButtonNode.swift
//  Cassowary
//
//  Created by nangezao on 2018/2/24.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import AVKit

open class ButtonNode: ControlNode {
    
    public let textNode = TextNode()
    public let imageNode = ImageNode()
    public let backgroundImageNode = ImageNode()
    
    public var space: CGFloat = 5 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public var layoutAxis = LayoutAxis.horizontal {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override open var highlighted: Bool {
        didSet {
            updateForState()
        }
    }
    
    override open var enabled: Bool {
        didSet {
            updateForState()
        }
    }
    
    override open var selected: Bool {
        didSet {
            updateForState()
        }
    }
    
    public var textFirst = false
    
    private var currentState: UIControl.State {
        if !enabled {
            return .disabled
        } else if highlighted {
            return .highlighted
        } else if selected {
            return .selected
        } else {
            return .normal
        }
    }
    
    private lazy var titleState = StatePicker<String>()
    private lazy var titleColorState = StatePicker<UIColor>()
    private lazy var attributeTitleState = StatePicker<NSAttributedString>()
    private lazy var imageState = StatePicker<UIImage>()
    private lazy var backgroundImageState = StatePicker<UIImage>()
    private lazy var backgroundColorState = StatePicker<UIColor>()
    
    public override init() {
        super.init()
        userInteractionEnabled = true
        addSubnode(backgroundImageNode)
        addSubnode(textNode)
        addSubnode(imageNode)
        backgroundImageNode.userInteractionEnabled = false
        textNode.userInteractionEnabled = false
        imageNode.userInteractionEnabled = false
    }
    
    // you can set the image, title color, title shadow color, and background image to use for each state. you can specify data
    // for a combined state by using the flags added together. in general, you should specify a value for the normal state to be used
    // by other states which don't have a custom value set
    
    // default is nil. title is assumed to be single line
    open func setTitle(_ title: String?, for state: UIControl.State) {
        titleState.update(state: state, with: title)
        updateContent()
    }
    
    // default if nil. use opaque white
    open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        titleColorState.update(state: state, with: color)
        updateForState()
    }
    
    // default is nil. should be same size if different for different states
    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        imageState.update(state: state, with: image)
        updateContent()
    }
    
    // default is nil
    open func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        backgroundImageState.update(state: state, with: image)
        updateContent()
    }
    
    
    // default is nil. title is assumed to be single line
    open func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        attributeTitleState.update(state: state, with: title)
        updateContent()
    }
    
    open func setBackgroundColor(color: UIColor?, for state: UIControl.State) {
        backgroundColorState.update(state: state, with: color)
        updateForState()
    }
    
    override open func layoutSubItems() {
        backgroundImageNode.frame = bounds
        updateButtonLayout()
    }
    
    override open var itemIntrinsicContentSize: CGSize {
        let title = textNode.text
        let attribubteTitle = textNode.attributeText
        
        let image = imageState.value(for: currentState)
        let backgroundImage = backgroundImageState.value(for: currentState)
        
        // no title,use Image size as it's contentSize
        if title != nil || attribubteTitle != nil {
            let titleSize = textNode.itemIntrinsicContentSize
            let imageSize = imageNode.itemIntrinsicContentSize
            if imageSize == .zero {
                return titleSize
            }
            return titleSize.combineTo(imageSize, space: space, isVertical: layoutAxis == .vertical)
            
        } else {
            if let backgroundImage = backgroundImage {
                return backgroundImage.size
            } else if let image = image {
                return image.size
            }
        }
        return .zero
    }
    
    func updateButtonLayout() {
        
        switch layoutAxis {
        case .horizontal:
            layoutForHorizontal()
            
        case .vertical:
            layoutForVertical()
        }
    }
    
    func layoutForHorizontal() {
        let textSize = textNode.sizeThatFit(bounds.size)
        let imageSize = imageNode.sizeThatFit(bounds.size)
        
        if textSize.isEmpty {
            imageNode.frame = AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
            return
        }
        if imageSize.isEmpty {
            textNode.frame = AVMakeRect(aspectRatio: textSize, insideRect: bounds)
            return
        }
        
        if textFirst {
            let rect = bounds.constraint(lhs: textSize,
                                         rhs: imageSize,
                                         space: space)
            textNode.frame = rect.0
            imageNode.frame = rect.1
        } else {
            let rect = bounds.constraint(lhs: imageSize,
                                         rhs: textSize,
                                         space: space)
            textNode.frame = rect.1
            imageNode.frame = rect.0
        }
    }
    
    func layoutForVertical() {
        let textSize = textNode.sizeThatFit(bounds.size)
        let imageSize = imageNode.sizeThatFit(bounds.size)
        
        if textSize.isEmpty {
            imageNode.frame = AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
            return
        }
        if imageSize.isEmpty {
            textNode.frame = AVMakeRect(aspectRatio: textSize, insideRect: bounds)
            return
        }
        
        if textFirst {
            let rects = bounds.constraint(ths: textSize,
                                          bhs: imageSize,
                                          space: space)
            textNode.frame = rects.0
            imageNode.frame = rects.1
        }
        else {
            let rects = bounds.constraint(ths: imageSize,
                                          bhs: textSize,
                                          space: space)
            textNode.frame = rects.1
            imageNode.frame = rects.0
        }
    }
    
    func updateForState() {
        backgroundImageNode.image = backgroundImageState.value(for: currentState)
        textNode.text = titleState.value(for: currentState) ?? ""
        imageNode.image = imageState.value(for: currentState)
        
        if let color = backgroundColorState.value(for: currentState) {
            backgroundColor = color
        } else {
            backgroundColor = .clear
        }
        
        if let textColor = titleColorState.value(for: currentState) {
            textNode.textColor = textColor
        }
        
        if let attributeString = attributeTitleState.value(for: currentState) {
            textNode.attributeText = attributeString
        }
        
        if backgroundImageNode.image == nil {
            backgroundImageNode.hidden = true
        }
    }
    
    private func updateContent() {
        updateForState()
        invalidateIntrinsicContentSize()
    }
    
    private func contentRectForbounds(_ rect: CGRect) -> CGRect {
        return rect
    }
}

// model Object to hold values for different state
// so that we don't need to repeat the same logic for pickering value
struct StatePicker<T> {
    
    private var stateTable = [UIControl.State: T]()
    
    mutating func update(state: UIControl.State, with value: T?) {
        
        // rawValue for UIControlStateNormal is 0
        // UIControlState.contains(.normal) always return true
        // so we have to deal this situation seperately
        
        if state == .normal {
            stateTable[.normal] = value
        } else {
            let states: [UIControl.State] = [.highlighted, .selected, .disabled]
            
            // flatten state and value
            states.forEach {
                if state.contains($0) {
                    stateTable[$0] = value
                }
            }
        }
    }
    
    func value(for state: UIControl.State) -> T? {
        if let value = stateTable[state] {
            return value
        }
        return stateTable[.normal]
    }
    
}

extension UIControl.State: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}


