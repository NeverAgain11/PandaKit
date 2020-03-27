//
//  AsycDisplayLayer.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2017/12/1.
//  Copyright © 2017年 nange. All rights reserved.
//

import UIKit

let QueueLabel = "com.nangezao.AsycDisplayQueue"

private let AsyncDisplayQueue = DispatchQueue(label: QueueLabel,
                                              qos: .userInteractive,
                                             target: .global())

public typealias CancelBlock = () -> Bool

public final class AsyncDisplayLayer: CALayer {
    
    public typealias AsyncAction = (Bool) -> ()
    public typealias ContentAction = (CancelBlock) -> (UIImage?)
    
    public var displaysAsynchronously = true
    
    public var willDisplayAction: AsyncAction? = nil
    public var displayAction: AsyncAction? = nil
    public var didDisplayAction: AsyncAction? = nil
    public var contentAction: ContentAction? = nil
    
    private var sentinel = Sentinel()
    
    override init() {
        super.init()
        contentsScale = UIScreen.main.scale
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func display() {
        clear()
        displayAsync(displaysAsynchronously)
    }
    
    func cancel() {
        sentinel.increase()
    }
    
    private func displayAsync(_ async: Bool) {
        
        willDisplayAction?(async)
        let value = sentinel.value
        let isCanceled = {
            return self.sentinel.value != value
        }
        
        if async {
            AsyncDisplayQueue.async {
                guard let image = self.contentAction?(isCanceled) else { return }
                
                DispatchQueue.main.async {
                    if isCanceled() { return }
                    self.contents = image.cgImage
                    self.didDisplayAction?(async)
                }
            }
        }
        else {
            guard let image = self.contentAction?(isCanceled) else { return }
            self.contents = image.cgImage
            self.didDisplayAction?(async)
        }
        
    }
    
    func clear() {
        contents = nil
        cancel()
    }
    
    deinit {
        clear()
    }
}

private class Sentinel {
    var value: Int64 = 0
    
    func increase() {
        OSAtomicIncrement64(&value)
    }
}
