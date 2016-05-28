//
//  AddAttachmentViewController.swift
//  Notes
//
//  Created by Chris Ritter on 28/05/2016.
//  Copyright © 2016 Ridaste Software Enterprises. All rights reserved.
//

import Cocoa

protocol AddAttachmentDelegate {
    func addFile()
}

class AddAttachmentViewController: NSViewController {
    
    var delegate : AddAttachmentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addFile(sender: AnyObject) {
        self.delegate?.addFile()
    }
}
