//
//  NumbersOnly.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import SwiftUI

class NumbersOnly: ObservableObject {
    @Published var value = "0" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            if value != filtered {
                value = filtered
            }
        }
    }
    
    var numericValue: Int64 {
        get {
            Int64(value)!
        }
        
        set(newValue) {
            value = String(newValue)
        }
    }
}
