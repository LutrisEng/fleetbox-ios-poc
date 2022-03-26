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

class ExportEnvelopeTemplate {
    var vehicle: Vehicle?
    var shops: [Shop] = []
    var tireSets: [TireSet] = []

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
    }

    init(context: NSManagedObjectContext, envelope: Fleetbox_Export_ExportEnvelope) {
        shops = envelope.shops.map { $0.importShop(context: context) }
        tireSets = envelope.tireSets.map { $0.importTireSet(context: context) }
        vehicle = envelope.vehicle.importVehicle(context: context, envelope: self)
    }

    func export() -> Fleetbox_Export_ExportEnvelope? {
        guard let vehicle = vehicle else {
            return nil
        }

        var envelope = Fleetbox_Export_ExportEnvelope()
        envelope.vehicle = Fleetbox_Export_Vehicle(envelope: self, vehicle: vehicle)
        envelope.shops = shops.map { Fleetbox_Export_Shop(shop: $0) }
        envelope.tireSets = tireSets.map { Fleetbox_Export_TireSet(tireSet: $0) }
        return envelope
    }
}
