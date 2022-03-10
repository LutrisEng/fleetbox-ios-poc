//
//  Shop.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/2/22.
//

import Foundation
import CoreData

extension Shop {
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}
