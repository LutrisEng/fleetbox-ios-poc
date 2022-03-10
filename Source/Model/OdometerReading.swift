//
//  OdometerReading.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import CoreData

extension OdometerReading {
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        vehicle?.objectWillChange.send()
    }
}
