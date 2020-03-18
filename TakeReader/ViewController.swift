//
//  ViewController.swift
//  TakeReader
//
//  Created by Volker Wolf on 12/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Cocoa
import AudioToolbox

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
       
    var viewModel = ViewModel()
    var selectedTake: Int = -1
    var selectedTakeInfo: AudioFormatInfo?
    
    @IBOutlet weak var container: NSView!
    var formatPropertyView: FormatPropertyViewController!
    
    @IBOutlet weak var addTakeBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        formatPropertyView = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "FormatPropertyViewController") as! FormatPropertyViewController
        
        formatPropertyView.view.frame = self.container.bounds
        self.container.addSubview(formatPropertyView.view)
        
        addTakeBtn.isEnabled = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /**
     Select directory with takes
     
    */
    @IBAction func selectTakeBtn(_ sender: NSButton) {
        //var selectedDirectory: URL?
        
//        DispatchQueue.main.sync {
//            selectedDirectory = self.selectTakeDirectory()
//        }
        let selectedDirectory = selectTakeDirectory()
        
        
        if selectedDirectory != nil {
            print(selectedDirectory!)
            // now check content of directory
            let dirParser = DirectoryParser(pathToDirectory: selectedDirectory!, fileTypes : ["wav"])
            let takes = dirParser.directoryContentForType()
            for (index, take) in takes.enumerated() {
                var takeModel = Take()
                takeModel.id = index
                takeModel.name = take.lastPathComponent
                takeModel.path = take

                do {
                    let itemResourceValues = try take.resourceValues(forKeys: [URLResourceKey.creationDateKey, URLResourceKey.fileSizeKey])
                    takeModel.recorded = itemResourceValues.creationDate
                    var fileSize = itemResourceValues.fileSize
                    if fileSize! > 0 {
                        takeModel.size = fileSize! / 1024
                    }
//                    try print(take.promisedItemResourceValues(forKeys: [URLResourceKey.creationDateKey]))
//                    try print(take.promisedItemResourceValues(forKeys: [URLResourceKey.fileSizeKey]))
                } catch {
                    
                }
                viewModel.takes.append(takeModel)
            }

        }
        
        tableView.reloadData()
    }
    
    @IBAction func addTakeBtn(_ sender: NSButton) {
    }
    
    @IBAction func jsonTestBtn(_ sender: NSButton) {
        let fileUrl = JsonParser().selectJsonFile()
        
        do {
            let data = try Data(contentsOf: fileUrl!, options: .mappedIfSafe)
            
            let jsonData = JsonParser().readJsonFile(data: data)
            print(jsonData)
            
        } catch {
            print("Error reading file: \(fileUrl)")
        }
        
        
    }
    
    
    /**
     Sheet modal to select directory
     
    */
    private func selectTakeDirectory() -> URL? {
        var directoryURL: URL?
        
        let dialog = NSOpenPanel();
        
        dialog.title = "Select Directory With Takes"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canCreateDirectories = false
        
        if (dialog.runModal() == NSModalResponseOK) {
            directoryURL = dialog.directoryURL
            print("Select take directory result: \(directoryURL)")
        } else {
            //return
        }

        return directoryURL
        
        // dialog.beginSheetModal is asycn
//        dialog.beginSheetModal(for: self.view.window! ) { (response) in
//            if response == NSModalResponseOK {
//                directoryURL = dialog.directoryURL
//                print("Select take directory result: \(directoryURL)")
//                
//            }
//            
//            if response == NSModalResponseCancel {
//                print("Select take directory canceled")
//            }
//        }
//        return directoryURL
    }
    
    
    func loadSound(takeIdx: Int) {
        print("load: \(viewModel.takes[takeIdx].path?.absoluteString)")
        selectedTake = takeIdx
        let fd = openFile(url: viewModel.takes[takeIdx].path!)
        
        var status: OSStatus = noErr
        var propertySize: UInt32 = 0
        var writeable: UInt32 = 0
        
        // section magic cookie data
        status = AudioFileGetPropertyInfo(fd!, kAudioFilePropertyMagicCookieData, &propertySize, &writeable)
        if status != noErr {
            status.logError(extras: "AudioFileGetPropertyInfo for kAudioFilePropertyMagicCookieData")
        } else {
            let magic: UnsafeMutablePointer<CChar> = UnsafeMutablePointer<CChar>.allocate(capacity: Int(propertySize))
            status = AudioFileGetProperty(fd!, kAudioFilePropertyMagicCookieData, &propertySize, magic)
            if status != noErr {
                status.logError(extras: "AudioFileGetProperty for kAudioFilePropertyMagicCookieData")
            }

        }
        
        
        // Audiostream format info
        var desc: AudioStreamBasicDescription = AudioStreamBasicDescription()
        var descSize: UInt32 = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        let magic: UnsafeMutablePointer<CChar> = UnsafeMutablePointer<CChar>.allocate(capacity: Int(propertySize))
        status = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, propertySize, magic, &descSize, &desc)
        if status != noErr {
            status.logError()
        } else {
            print("desc: \(desc)")
        }
        
        // format description into &desc
        // something like: AudioStreamBasicDescription(mSampleRate: 44100.0, mFormatID: 1819304813, mFormatFlags: 12, mBytesPerPacket: 2, mFramesPerPacket: 1, mBytesPerFrame: 2, mChannelsPerFrame: 1, mBitsPerChannel: 16, mReserved: 0)
        status = AudioFileGetProperty(fd!, kAudioFilePropertyDataFormat, &descSize, &desc)
        if status != noErr {
            status.logError()
        } else {
            print("DataFormat : \(desc)")
        }
        
        // something like: Linear PCM, 16 bit little-endian signed integer, 1 channels, 44100 Hz
        var formatDesc: CFString = String() as CFString
        var formatNameSize: UInt32 = UInt32(MemoryLayout<CFString>.size)
        status = AudioFormatGetProperty(kAudioFormatProperty_FormatName, descSize, &desc, &formatNameSize, &formatDesc)
        if (status != noErr) {
            status.logError()
        } else {
            print("FormatDesc: \(formatDesc)")
        }
        
        // struct AudioFormatInfo,
        // something like: AudioFormatInfo(mASBD: __C.AudioStreamBasicDescription(mSampleRate: 44100.0, mFormatID: 1819304813, mFormatFlags: 12, mBytesPerPacket: 2, mFramesPerPacket: 1, mBytesPerFrame: 2, mChannelsPerFrame: 1, mBitsPerChannel: 16, mReserved: 0), mMagicCookie: 0x0000628000008eb0, mMagicCookieSize: 0)
        // This is the one to use?
        var formatInfo: AudioFormatInfo = AudioFormatInfo(mASBD: desc, mMagicCookie: magic, mMagicCookieSize: propertySize)
        print("FormatInfo: \(formatInfo)")
        selectedTakeInfo = formatInfo
    
        var outputFormatInfoSize: UInt32 = 0
        status = AudioFormatGetPropertyInfo(
            kAudioFormatProperty_FormatList,
            UInt32(MemoryLayout<AudioFormatInfo>.size),
            &formatInfo,
            &outputFormatInfoSize
        )
        if status != noErr {
            status.logError(extras: "AudioFormatGetPropertyInfo for kAudioFormatProperty_FormatList")
        } else {
            
        }
        
        
        status = AudioFormatGetPropertyInfo(
            kAudioFormatProperty_FormatInfo,
            UInt32(MemoryLayout<AudioFormatInfo>.size),
            &formatInfo,
            &outputFormatInfoSize
        )
        print("status formatInfo: \(status)")
        
        if status != noErr {
            status.logError()
        } else {
            print("formatInfo status: \(status), outputFormatInfoSize: \(outputFormatInfoSize)")
        }
        
        // format list
        let formatListItem: UnsafeMutablePointer<AudioFormatListItem> = UnsafeMutablePointer<AudioFormatListItem>.allocate(capacity: Int(outputFormatInfoSize))
        status = AudioFormatGetProperty(
            kAudioFormatProperty_FormatList,
            UInt32(MemoryLayout<AudioFormatInfo>.size),
            &formatInfo,
            &outputFormatInfoSize,
            formatListItem
        )
        if status != noErr {
            status.logError(extras: "AudioFormatGetProperty.kAudioFormatProperty_FormatList")
        } else {
            print("AudioFormatGetProperty.kAudioFormatProperty_FormatList: \(formatListItem)")
        }

        
        status = AudioFormatGetProperty(
            kAudioFormatProperty_FormatInfo,
            UInt32(MemoryLayout<AudioFormatInfo>.size),
            &formatInfo,
            &outputFormatInfoSize,
            formatListItem
        )
        if status != noErr {
            status.logError(extras: "AudioFormatGetProperty for kAudioFormatProperty_FormatInfo")
        } else {
            print("AudioFormatGetProperty.kAudioFormatProperty_FormatInfo: \(formatListItem)")
            print("outputFormatInfoSize: \(outputFormatInfoSize)")
        }
//
        print("MemoryLayout<AudioFormatListItem: \(UInt32(MemoryLayout<AudioFormatListItem>.size))")
        print("current outputFormatInfoSize: \(outputFormatInfoSize)")
        
        // UInt32(MemoryLayout<AudioFormatListItem>.size) is 48???
        let itemCount =  UInt32(MemoryLayout<AudioFormatListItem>.size) / outputFormatInfoSize
        print("itemCount: \(itemCount)")
        
        for idx in 0..<itemCount {
            let item: AudioFormatListItem = formatListItem.advanced(by: Int(idx)).pointee
            print("channel layout tag is \(item.mChannelLayoutTag), mASBD is \(item.mASBD)")
        }
        //let un: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        
        //status = AudioFileGetPropertyInfo(fd!, kAudioFilePropertyBitRate, &propertySize, un)
        
        closeFile(fd: fd!)
        
        formatPropertyView.setData(selectedTakeInfo: selectedTakeInfo!, selectedTake: viewModel.takes[selectedTake])
    }
    
    
    func openFile(url: URL) -> AudioFileID? {
        var fd: AudioFileID? = nil
        
        AudioFileOpenURL(url as CFURL, .readPermission, kAudioFileWAVEType, &fd)
        
        return fd
    }
    
    func closeFile(fd: AudioFileID) {
        AudioFileClose(fd)
    }
}


// MARK: TableView Extensions

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.takes.count
    }
}


extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let take = viewModel.takes[row]
        
        if tableColumn?.identifier == "columnTakeId" {
            let cellIdentifier = "cellTakeId"
            
            guard let cellView = tableView.make(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.integerValue = take.id ?? 0
            
            return cellView
        }
        
        if tableColumn?.identifier == "columnTakeName" {
            let cellIdentifire = "cellTakeName"
            
            guard let cellView = tableView.make(withIdentifier: cellIdentifire, owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.stringValue = take.name ?? ""
            return cellView
        }
        
        if tableColumn?.identifier == "columnTakeRecorded" {
            let cellIdentifire = "cellTakeRecorded"
            
            guard let cellView = tableView.make(withIdentifier: cellIdentifire, owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.stringValue = (take.recorded?.description(with: nil))!
            return cellView
        }
        
        if tableColumn?.identifier == "columnTakeSize" {
            let cellIdentifire = "cellTakeSize"
            
            guard let cellView = tableView.make(withIdentifier: cellIdentifire, owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.integerValue = take.size ?? 0
            return cellView
        }
        return nil
    }
    
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        
        print(selectedRow)
        
        guard let soundURL = viewModel.takes[selectedRow].path else {
            print("no url for take?")
            return
        }
        loadSound(takeIdx: selectedRow)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24.0
    }
    
   
}


extension OSStatus {
    
    func errorToMsg() -> String {
        
        if self < 0 {
            
            let statusString =  NSError(domain: NSOSStatusErrorDomain, code: Int(self), userInfo: nil)
            print(statusString)
            return ("Error code < 0!")
        }
//        
//        let error = UTCreateStringForOSType(OSType(self))
//        print( UTCreateStringForOSType(OSType(self)))
//        print( UTCreateStringForOSType(OSType(self)).takeUnretainedValue())
//        print( UTCreateStringForOSType(OSType(self)).takeRetainedValue())
        
        
        
        let osTypeString = UTCreateStringForOSType(OSType(self)).takeRetainedValue()
        
        switch (osTypeString as NSString) {
        case "pty?" :
            return "kAudioServicesUnsupportedPropertyError, This property is not supported."
        
        case "!siz" :
            return "kAudioServicesBadPropertySizeError, The size of this property was not correct."
            
        default: return "Unknow Error \(self)"
        }
    }
    
    func logError() {
        
        let details = errorToMsg()
        NSLog("Error \(self), \(details)")
    }
    
    func logError(extras: String) {
        let details = errorToMsg()
        NSLog("Error \(self), \(details),\n Extras: \(extras)")
    }
}
