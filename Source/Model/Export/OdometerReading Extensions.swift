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

extension Fleetbox_Export_OdometerReading {
    init(settings: ExportSettings, odometerReading: OdometerReading) {
        if let performedAt = odometerReading.at {
            self.performedAt = Int64(performedAt.timeIntervalSince1970)
        }
        reading = odometerReading.reading
        includeTime = odometerReading.includeTime
    }

    func importOdometerReading(context: NSManagedObjectContext, vehicle: Vehicle) -> OdometerReading {
        let odometerReading = OdometerReading(context: context)
        odometerReading.vehicle = vehicle
        if hasPerformedAt {
            odometerReading.at = Date(timeIntervalSince1970: TimeInterval(performedAt))
        }
        odometerReading.reading = reading
        odometerReading.includeTime = includeTime
        return odometerReading
    }
}
