//
//  JsonParser.swift
//  TakeReader
//
//  Created by Volker Wolf on 18/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Foundation
import Cocoa

class JsonParser {
    
/**
 Select one *.json file and parse contents
*/
    
    func readJsonFile(data: Data) -> [String: AnyObject]? {
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dict = result as? [String: AnyObject] {
                return dict
            }
        } catch {
            
        }
        return nil
    }
    
    func selectJsonFile() -> URL? {
        var fileURL: URL?
        
        let dialog = NSOpenPanel()
        
        dialog.title = "Select Json file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        dialog.allowsMultipleSelection = false
        dialog.canCreateDirectories = false
        
        if (dialog.runModal() == NSModalResponseOK) {
            fileURL = dialog.url
        } else {
            
        }
        
        return fileURL
    }
}
