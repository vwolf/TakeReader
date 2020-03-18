//
//  LoadableView.swift
//  TakeReader
//
//  Created by Volker Wolf on 17/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Cocoa

protocol LoadableView: class {
    var mainView: NSView? { get set }
    func load(fromNIBNamed nibName: String) -> Bool
}

extension LoadableView where Self: NSView {
    
    func load(fromNIBNamed nibName: String) -> Bool {
        var topLevelObjects = NSArray()
        
        if Bundle.main.loadNibNamed("AudioFormatItem", owner: self, topLevelObjects: &topLevelObjects) {
            let views = (topLevelObjects as Array).filter { $0 is NSView }
            
            if views.count > 0 {
                guard let view = views[0] as? NSView else { return false }
                
                mainView = view
                self.addSubview(mainView!)
                
                mainView?.translatesAutoresizingMaskIntoConstraints = false
                mainView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                mainView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                mainView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                mainView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

                
                return true
            }
        }
        
        return false
    }
    
}
