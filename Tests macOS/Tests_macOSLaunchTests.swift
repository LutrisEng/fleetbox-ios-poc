//
//  Tests_macOSLaunchTests.swift
//  Tests macOS
//
//  Created by Piper McCorkle on 2/28/22.
//

import XCTest

class Tests_macOSLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        return app
    }

    func testLaunch() throws {
        let app = launch()

        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
