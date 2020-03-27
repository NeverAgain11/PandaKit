//
//  TextNode.swift
//
//  Created by nangezao on 2017/7/19.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit

public typealias TextTapAction = (NSRange) -> ()

open class TextNode: ControlNode,TextRenderable {
    
    public private(set) lazy var textHolder = TextAttributesHolder(self)
    
    public func textDidUpdate(for attribute: AnyKeyPath) {
        if attribute == \TextRenderable.textColor {
            setNeedsDisplay()
        } else {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    override open var itemIntrinsicContentSize: CGSize {
        return textHolder.itemIntrinsicContentSize
    }
    
    override open func contentSizeFor(maxWidth: CGFloat) -> CGSize {
        
        if numberOfLines == 1 { return InvaidIntrinsicSize }
        
        return textHolder.sizeFor(maxWidth: maxWidth)
    }
    
    override open func drawContent(in context: CGContext) {
        textHolder.render(for: bounds).drawInContext(context, bounds: bounds)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?, currentTraitCollection: UITraitCollection) {
        super.traitCollectionDidChange(previousTraitCollection, currentTraitCollection: currentTraitCollection)
        
        if #available(iOS 13.0, *) {
            if currentTraitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setNeedsDisplay()
            }
        }
    }
}
