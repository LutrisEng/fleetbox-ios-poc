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
    
    func assertVehiclesSimilar(_ a: Vehicle, _ b: Vehicle) {
        XCTAssertEqual(a.displayNameWithFallback, b.displayNameWithFallback)
        XCTAssertEqual(a.odometer, b.odometer)
        XCTAssertEqual(a.logItems.chrono.first!.at, b.logItems.chrono.first!.at)
        XCTAssertEqual(
            try a
                .lastLineItem(type: "engineOilChange")!
                .getFieldValueString("viscosity"),
            try b
                .lastLineItem(type: "engineOilChange")!
                .getFieldValueString("viscosity")
        )
    }

    func testRoundtrip() throws {
        let fixtures = try env.addFixtures()
        let exported = try fixtures.vehicle.export(settings: ExportSettings())!
        let newEnvironment = TestEnvironment()
        let newVehicle = try Vehicle.importData(exported, context: newEnvironment.viewContext)!
        assertVehiclesSimilar(fixtures.vehicle, newVehicle)
    }

    func testAdvancedFixtures() throws {
        let vehicle = try env.controller.useAdvancedFixtures()
        let exported = try vehicle.export(settings: ExportSettings())!
        let newEnvironment = TestEnvironment()
        let newVehicle = try Vehicle.importData(exported, context: newEnvironment.viewContext)!
        assertVehiclesSimilar(vehicle, newVehicle)
    }
}
