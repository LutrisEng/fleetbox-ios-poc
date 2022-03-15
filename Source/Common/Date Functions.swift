//
//  Date Functions.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

import Foundation

func dateDifference(_ first: Date?, _ second: Date?) -> Double {
    abs((first ?? Date.distantPast).timeIntervalSince1970 - (second ?? Date.distantPast).timeIntervalSince1970)
}
