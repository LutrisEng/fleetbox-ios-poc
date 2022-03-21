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

class UILaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testVehicles() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Vehicles"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testVehicle() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Vehicle"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLogItem() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.tap()
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "Break-in oil change")).element.tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Line item"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLineItem() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "The Mazda CX-5")).element.tap()
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "Break-in oil change")).element.tap()
        app.tables.cells.containing(NSPredicate(format: "label contains[c] %@", "Engine oil changed")).element.tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Line item"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
