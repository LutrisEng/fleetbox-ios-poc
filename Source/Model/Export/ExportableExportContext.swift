//
//  ExportableExportContext.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

import Foundation

struct ExportableExportContext: Codable {
    let vehicle: ExportableVehicle
    let shops: [ExportableShop]
    let tireSets: [ExportableTireSet]
}
