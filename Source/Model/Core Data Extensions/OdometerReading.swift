//
//  OdometerReading.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import CoreData

extension OdometerReading {
    convenience init(context: NSManagedObjectContext, logItem: LogItem) {
        self.init(context: context)
        self.logItem = logItem
        vehicle = logItem.vehicle
        reading = logItem.vehicle?.odometer ?? 0
        at = logItem.performedAt ?? Date.now
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        vehicle?.objectWillChange.send()
    }
}
