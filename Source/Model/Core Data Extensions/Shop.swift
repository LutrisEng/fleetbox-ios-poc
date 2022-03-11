//
//  Shop.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/2/22.
//

import Foundation
import CoreData

extension Shop {
    var logItemsUnordered: Set<LogItem> {
        logItemsNs as? Set<LogItem> ?? []
    }
    
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        for logItem in logItemsUnordered {
            logItem.objectWillChange.send()
        }
    }
}
