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

extension Fleetbox_Export_ExportEnvelope {
    init(settings: ExportSettings, vehicle: Vehicle) {
        let tmpl = ExportEnvelopeTemplate(vehicle: vehicle)
        self.vehicle = Fleetbox_Export_Vehicle(envelope: tmpl, settings: settings, vehicle: vehicle)
        shops = tmpl.shops.map { Fleetbox_Export_Shop(settings: settings, shop: $0) }
        tireSets = tmpl.tireSets.map { Fleetbox_Export_TireSet(settings: settings, tireSet: $0) }
    }
}
