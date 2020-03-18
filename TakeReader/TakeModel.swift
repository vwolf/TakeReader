//
//  TakeModel.swift
//  TakeReader
//
//  Created by Volker Wolf on 12/03/20.
//  Copyright © 2020 devWolf. All rights reserved.
//

import Foundation
import AudioToolbox

struct Take {
    var id: Int?
    var name: String?
    var recorded: Date?
    var size: Int?
    var path: URL?
    var audioFormatInfo: AudioFormatInfo?
}
