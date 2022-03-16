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

class VehicleTest: XCTestCase {
    var env: TestEnvironment = TestEnvironment()

    override func setUpWithError() throws {
        env = TestEnvironment()
    }

    func testCreateVehicle() throws {
        _ = Vehicle(context: env.viewContext)
        try env.viewContext.save()
    }

    func testOdometer() throws {
        let vehicle = Vehicle(context: env.viewContext)
        XCTAssertEqual(vehicle.odometer, 0)
        let odometerReading = OdometerReading(context: env.viewContext)
        odometerReading.at = Date(timeIntervalSince1970: 1)
        odometerReading.vehicle = vehicle
        odometerReading.reading = 100
        XCTAssertEqual(vehicle.odometer, 100)
        let secondOdometerReading = OdometerReading(context: env.viewContext)
        secondOdometerReading.at = Date(timeIntervalSince1970: 2)
        secondOdometerReading.vehicle = vehicle
        secondOdometerReading.reading = 1000
        XCTAssertEqual(vehicle.odometer, 1000)
        try env.viewContext.save()
    }
}
