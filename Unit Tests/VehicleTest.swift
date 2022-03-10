//
//  Vehicle.swift
//  Tests iOS
//
//  Created by Piper McCorkle on 3/10/22.
//

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
