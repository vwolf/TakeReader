//
//  AudioFormatItem.swift
//  TakeReader
//
//  Created by Volker Wolf on 17/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Cocoa

class AudioFormatItem: NSView, LoadableView {
    
    @IBOutlet weak var propertyName: NSTextField!
    @IBOutlet weak var propertyValue: NSTextField!
    
    var mainView: NSView?
    
    init() {
        super.init(frame: NSRect.zero)
        
        _ = load(fromNIBNamed: "AudioFormatItem")
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
