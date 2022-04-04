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

extension Fleetbox_Export_TireSet {
    init(settings: ExportSettings, tireSet: TireSet) {
        aspectRatio = Int32(tireSet.aspectRatio)
        if let construction = tireSet.construction {
            self.construction = construction
        }
        diameter = Int32(tireSet.diameter)
        loadIndex = Int32(tireSet.loadIndex)
        if let make = tireSet.make {
            self.make = make
        }
        if let model = tireSet.model {
            self.model = model
        }
        if let speedRating = tireSet.speedRating {
            self.speedRating = speedRating
        }
        if let displayName = tireSet.userDisplayName {
            self.displayName = displayName
        }
        if let vehicleType = tireSet.vehicleType {
            self.vehicleType = vehicleType
        }
        width = Int32(tireSet.width)
        if let tin = tireSet.tin {
            self.tin = tin
        }
        hidden = tireSet.hidden
        breakin = tireSet.breakin
        warranties = tireSet.warranties.map {
            Fleetbox_Export_Warranty(settings: settings, warranty: $0)
        }
        baseMiles = tireSet.baseMiles
        if settings.includeAttachments {
            attachments = tireSet.attachments.map {
                Fleetbox_Export_Attachment(settings: settings, attachment: $0)
            }
        }
    }

    func importTireSet(context: NSManagedObjectContext) -> TireSet {
        let tireSet = TireSet(context: context)
        tireSet.aspectRatio = Int16(aspectRatio)
        tireSet.construction = construction
        tireSet.diameter = Int16(diameter)
        tireSet.loadIndex = Int16(loadIndex)
        tireSet.make = make
        tireSet.model = model
        tireSet.speedRating = speedRating
        tireSet.userDisplayName = displayName
        tireSet.vehicleType = vehicleType
        tireSet.width = Int16(width)
        tireSet.tin = tin
        tireSet.hidden = hidden
        tireSet.breakin = breakin
        for warranty in warranties {
            _ = warranty.importWarranty(context: context, underlying: tireSet)
        }
        tireSet.baseMiles = baseMiles
        for (index, attachment) in attachments.enumerated() {
            let obj = attachment.importAttachment(context: context, index: index)
            obj.tireSet = tireSet
        }
        return tireSet
    }
}
