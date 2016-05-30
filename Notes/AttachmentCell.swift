//
//  AttachmentCell.swift
//  Notes
//
//  Created by Chris Ritter on 26/05/2016.
//  Copyright © 2016 Ridaste Software Enterprises. All rights reserved.
//

import Cocoa

class AttachmentCell: NSCollectionViewItem {
    
    weak var delegate : AttachmentCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if (theEvent.clickCount == 2) {
            delegate?.openSelectedAttachment(self)
        }
    }
    
}
