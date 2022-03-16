//  SPDX-License-Identifier: GPL-3.0-or-later
//  Fleetbox, a tool for managing vehicle maintenance logs
//  Copyright (C) 2022 Lutris, Inc
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
