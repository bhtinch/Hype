//
//  Hype.swift
//  Hype
//
//  Created by Benjamin Tincher on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()) {
        self.body = body
        self.timestamp = timestamp
    }
}

extension CKRecord {
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey)
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
    }
}

extension Hype {
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date else { return nil }
        
        self.init(body: body, timestamp: timestamp)
    }
}
