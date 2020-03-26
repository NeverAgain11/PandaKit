//
//  WeiBoCell.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/2/26.
//  Copyright © 2018年 nange. All rights reserved.
//

import UIKit
import Panda

class WeiBoCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(statusNode.view)
        statusNode.width == UIScreen.main.bounds.width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let statusNode = StatusNode()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func update(for status: WBStatusViewModel, needLayout: Bool = true){
        statusNode.update(status, needLayout: needLayout)
        statusNode.layoutIfNeeded()
    }
}
