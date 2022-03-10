//
//  Dummy Data.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation

struct DummyData {
    let vehicleMake: String
    let vehicleModel: String
    let vin: String
    let vehicleName: String
    
    static let popCulture = DummyData(vehicleMake: "Knight Industries", vehicleModel: "Two Thousand", vin: "AAAAA000000000000", vehicleName: "KITT")
}

let dummyData = DummyData.popCulture
