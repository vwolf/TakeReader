//
//  DirectoryParser.swift
//  TakeReader
//
//  Created by Volker Wolf on 12/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Foundation

/**
 Parse content of a directory. 
 Extract allowed files of type
 
 */
class DirectoryParser: NSObject {
 
    /// URL to directory to parse
    var directorPath: URL
    
    /// file extension
    var fileTypes: [String]
    
    var files: [String] = [String]()
    var fileURLs: [URL] = [URL]()
    
    init( pathToDirectory: URL, fileTypes : [String]) {
        self.directorPath = pathToDirectory
        self.fileTypes = fileTypes
        
    }
    
    func directoryContentForType() -> [URL] {
        let fileProperties = [
            URLResourceKey.creationDateKey,
            URLResourceKey.fileSizeKey,
            URLResourceKey.typeIdentifierKey
        ]
        do {
            let content = try FileManager.default.contentsOfDirectory(at: directorPath, includingPropertiesForKeys: fileProperties, options: [])
            
            for url in content {
                print(url.absoluteString)
                print(url.lastPathComponent)
                print(url.pathExtension)
                if ( fileTypes.contains(url.pathExtension)) {
                    fileURLs.append(url)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return fileURLs
    }
    
    
    func directoryContent() {
        do {
            let content = try FileManager.default.contentsOfDirectory(atPath: directorPath.path)
            
            for c in content {
                print(c)
                files.append(c)
            }
        } catch  {
            print(error)
        }
    }

}
