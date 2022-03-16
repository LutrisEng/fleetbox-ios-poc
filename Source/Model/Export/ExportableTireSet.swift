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

struct ExportableTireSet: Codable {
    let aspectRatio: Int16
    let construction: String?
    let diameter: Int16
    let loadIndex: Int16
    let make: String?
    let model: String?
    let sortOrder: Int16
    let speedRating: String?
    let userDisplayName: String?
    let vehicleType: String?
    let width: Int16

    init(tireSet: TireSet) {
        aspectRatio = tireSet.aspectRatio
        construction = tireSet.construction
        diameter = tireSet.diameter
        loadIndex = tireSet.loadIndex
        make = tireSet.make
        model = tireSet.model
        sortOrder = tireSet.sortOrder
        speedRating = tireSet.speedRating
        userDisplayName = tireSet.userDisplayName
        vehicleType = tireSet.vehicleType
        width = tireSet.width
    }

    func importTireSet(context: NSManagedObjectContext) -> TireSet {
        let tireSet = TireSet(context: context)
        tireSet.aspectRatio = aspectRatio
        tireSet.construction = construction
        tireSet.diameter = diameter
        tireSet.loadIndex = loadIndex
        tireSet.make = make
        tireSet.model = model
        tireSet.sortOrder = sortOrder
        tireSet.speedRating = speedRating
        tireSet.userDisplayName = userDisplayName
        tireSet.vehicleType = vehicleType
        tireSet.width = width
        return tireSet
    }
}
