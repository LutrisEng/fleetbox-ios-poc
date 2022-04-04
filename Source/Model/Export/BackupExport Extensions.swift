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

import CoreData

extension Fleetbox_Export_BackupExport {
    init(context: NSManagedObjectContext, settings: ExportSettings) throws {
        let tmpl = try ExportEnvelopeTemplate(allFromContext: context)
        let vehiclesFetchRequest = NSFetchRequest<Vehicle>(entityName: "Vehicle")
        vehicles = try context.fetch(vehiclesFetchRequest)
            .map { Fleetbox_Export_Vehicle(envelope: tmpl, settings: settings, vehicle: $0) }
        shops = tmpl.shops.map { Fleetbox_Export_Shop(settings: settings, shop: $0) }
        tireSets = tmpl.tireSets.map { Fleetbox_Export_TireSet(settings: settings, tireSet: $0) }
    }

    func importBackup(context: NSManagedObjectContext) throws {
        let tmpl = ExportEnvelopeTemplate(context: context, backup: self)
        for vehicle in vehicles {
            _ = vehicle.importVehicle(context: context, envelope: tmpl)
        }
    }
}
