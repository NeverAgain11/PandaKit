//
//  ImageNode.swift
//
//  Created by nangezao on 2017/7/19.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit

public enum ContentMode {
    case scaleToFill
    case scaleAspectToFit
    case scaleAspectToFill
}

open class ImageNode: ControlNode {
    
    public var image: UIImage? {
        didSet {
            if image != oldValue {
                invalidateIntrinsicContentSize()
                setNeedsDisplay()
            }
        }
    }
    
    public var processor: ImageProcessor? = nil
    
    public var contentMode: ContentMode = .scaleAspectToFill {
        didSet {
            if oldValue != contentMode {
                setNeedsDisplay()
            }
        }
    }
    
    override open var itemIntrinsicContentSize: CGSize {
        if let image = image {
            return image.size
        }
        return .zero
    }
    
    override func contentForLayer(_ layer: AsyncDisplayLayer, isCancel: () -> Bool) -> UIImage? {
        guard let image = image, bounds.width > 0, bounds.height > 0 else {
            return nil
        }
        
        /// if image size equal to bounds and processor is nil, no need to process image
        if image.size == bounds.size && processor == nil {
            return image
        }
        
        let key = ImageKey(image: image, size: bounds.size,contentMode: contentMode, processor: processor)
        return ImageRender.imageForKey(key, isCancelled: isCancel)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?, currentTraitCollection: UITraitCollection) {
        super.traitCollectionDidChange(previousTraitCollection, currentTraitCollection: currentTraitCollection)
        
        guard #available(iOS 13.0, *), currentTraitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        
        setNeedsDisplay()
    }
}
