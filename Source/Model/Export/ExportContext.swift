//
//  ExportContext.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

import Foundation
import CoreData

class ExportContext {
    var vehicle: Vehicle?
    var shops: [Shop] = []
    var tireSets: [TireSet] = []

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }

    init(context: NSManagedObjectContext, exportContext: ExportableExportContext) {
        shops = exportContext.shops.map { $0.importShop(context: context) }
        tireSets = exportContext.tireSets.map { $0.importTireSet(context: context) }
        vehicle = exportContext.vehicle.importVehicle(context: context, exportContext: self)
    }

    func export() -> ExportableExportContext? {
        guard let vehicle = vehicle else {
            return nil
        }

        return ExportableExportContext(
            vehicle: ExportableVehicle(context: self, vehicle: vehicle),
            shops: shops.map { ExportableShop(shop: $0) },
            tireSets: tireSets.map { ExportableTireSet(tireSet: $0) }
        )
    }
}
