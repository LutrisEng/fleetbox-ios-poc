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

import XCTest
@testable import Fleetbox

class ExportTest: TestEnvironmentTestCase {
    func testExportWithoutErrors() throws {
        let fixtures = try env.addFixtures()
        let exported = try fixtures.vehicle.export(settings: ExportSettings())!
        XCTAssertNotEqual(exported.count, 0)
    }

    func testRoundtrip() throws {
        let fixtures = try env.addFixtures()
        let exported = try fixtures.vehicle.export(settings: ExportSettings())!
        let newEnvironment = TestEnvironment()
        let newVehicle = try Vehicle.importData(exported, context: newEnvironment.viewContext)!

        XCTAssertEqual(newVehicle.displayNameWithFallback, fixtures.vehicle.displayNameWithFallback)
        XCTAssertEqual(newVehicle.odometer, fixtures.vehicle.odometer)
        XCTAssertEqual(newVehicle.logItems.first!.at, fixtures.vehicle.logItems.first!.at)
        XCTAssertEqual(
            try newVehicle
                .lastLineItem(type: "engineOilChange")!
                .getFieldValueString("viscosity"),
            try fixtures.vehicle
                .lastLineItem(type: "engineOilChange")!
                .getFieldValueString("viscosity")
        )
    }
}
