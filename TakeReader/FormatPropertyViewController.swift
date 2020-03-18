//
//  FormatPropertyViewController.swift
//  TakeReader
//
//  Created by Volker Wolf on 17/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Cocoa
import AudioToolbox

class FormatPropertyViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!

    var selectedTakeInfo: AudioFormatInfo?
    var mockData = [["name", "value"], ["next name", "next value"]]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    public func setData(selectedTakeInfo: AudioFormatInfo, selectedTake: Take) {
        print("FormatPropertyViewController.setData()")
        let bits = selectedTakeInfo.mASBD.mBitsPerChannel
        let sampleRate = selectedTakeInfo.mASBD.mSampleRate
        let channelsPerFrame = selectedTakeInfo.mASBD.mChannelsPerFrame
        
        
        // Add selectedTakeInfo
        mockData = [["bitsPerChannel", String(bits)],
                    ["sampleRate", String(sampleRate)],
                    ["channels per frame", String(channelsPerFrame)]]
        
        mockData.append(["Category", "category"])
        mockData.append(["Subcategroy", "subcategory"])
        mockData.append(["path", (selectedTake.path?.absoluteString)!])
        mockData.append(["recorded at", (selectedTake.recorded?.description(with: nil))! ])
        
        tableView.reloadData()
    }

}


extension FormatPropertyViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("numberOfRows: \(mockData.count)")
        return mockData.count
    }
}


extension FormatPropertyViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("tableView viewFor tablecolumn row: \(row)")
        let columnData = mockData[row]
        
        let view = AudioFormatItem()
        view.propertyName.stringValue = columnData[0]
        view.propertyValue.stringValue = columnData[1]
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 80.0
    }
}
