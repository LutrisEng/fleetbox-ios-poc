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
import Sentry

struct PersistenceController {
    static let shared = PersistenceController()
    static let managedObjectModelURL = Bundle.main.url(forResource: "Fleetbox", withExtension: "momd")!
    static let managedObjectModel = NSManagedObjectModel(contentsOf: managedObjectModelURL)!

    #if DEBUG
    struct Fixtures {
        let shop: Shop
        let vehicle: Vehicle
        let logItem: LogItem
        let odometerReading: OdometerReading
        let lineItem: LineItem
        let tireSet: TireSet

        // swiftlint:disable:next function_body_length
        init(viewContext: NSManagedObjectContext) throws {
            vehicle = Vehicle(context: viewContext)
            vehicle.displayName = "The Mazda CX-5"
            vehicle.year = 2022
            vehicle.make = "BMW"
            vehicle.model = "M340i"
            vehicle.vin = "3MW5U7J09N8C40580"
            let factory = Shop(context: viewContext)
            factory.name = "BMW"
            let factoryLogItem = LogItem(context: viewContext)
            factoryLogItem.displayName = "Vehicle manufactured"
            factoryLogItem.vehicle = vehicle
            factoryLogItem.performedAt = Date(timeIntervalSince1970: 1641452583)
            factoryLogItem.shop = factory
            let factoryOdometerReading = OdometerReading(context: viewContext)
            factoryOdometerReading.reading = 0
            factoryOdometerReading.at = factoryLogItem.performedAt!
            factoryOdometerReading.vehicle = vehicle
            factoryOdometerReading.logItem = factoryLogItem
            tireSet = TireSet(context: viewContext)
            tireSet.make = "Bridgestone"
            tireSet.model = "Turanza"
            let factoryTireLineItem = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "mountedTires"
            )
            try factoryTireLineItem.setFieldValue("tireSet", value: tireSet)
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "engineOilChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "engineOilFilterChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "transmissionFluidChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "transmissionFluidFilterChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "coolantChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "brakeFluidChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "engineAirFilterChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "cabinAirFilterChange"
            )
            _ = LineItem(
                context: viewContext,
                logItem: factoryLogItem,
                typeId: "batteryReplacement"
            )
            shop = Shop(context: viewContext)
            shop.name = "BMW of West Houston"
            logItem = LogItem(context: viewContext)
            logItem.displayName = "Break-in oil change"
            logItem.vehicle = vehicle
            logItem.performedAt = Date(timeIntervalSince1970: 1643007783)
            logItem.shop = shop
            odometerReading = OdometerReading(context: viewContext)
            odometerReading.reading = 1452
            odometerReading.at = logItem.performedAt
            odometerReading.vehicle = vehicle
            odometerReading.logItem = logItem
            lineItem = LineItem(context: viewContext, logItem: logItem, typeId: "engineOilChange")
            try lineItem.setFieldValue("viscosity", value: "0W-20")
            try lineItem.setFieldValue("brand", value: "BMW")
            try lineItem.setFieldValue("partNumber", value: "83-21-2-463-673")
            let secondLineItem = LineItem(context: viewContext, logItem: logItem)
            secondLineItem.typeId = "engineOilFilterChange"
            try secondLineItem.setFieldValue("brand", value: "BMW")
            try secondLineItem.setFieldValue("partNumber", value: "11-42-8-583-898")
            let laterOdometerReading = OdometerReading(context: viewContext)
            laterOdometerReading.reading = 6871
            laterOdometerReading.at = Date(timeIntervalSince1970: 1646550183)
            laterOdometerReading.vehicle = vehicle
            try viewContext.save()
        }
    }

    struct Preview {
        let controller: PersistenceController
        let viewContext: NSManagedObjectContext
        let fixtures: Fixtures

        init() throws {
            controller = PersistenceController(inMemory: true)
            viewContext = controller.container.viewContext
            fixtures = try Fixtures(viewContext: viewContext)
        }
    }

    // swiftlint:disable:next force_try
    static var preview: Preview = try! Preview()
    #endif

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        var name = "Fleetbox"
        if inMemory {
            name += ProcessInfo().globallyUniqueString
        }
        container = NSPersistentCloudKitContainer(
            name: name,
            managedObjectModel: PersistenceController.managedObjectModel
        )
        if inMemory {
            container.persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            ]
        } else {
            let description = container.persistentStoreDescriptions.first!
            description.type = NSSQLiteStoreType
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            description.setOption(true as NSNumber, forKey: remoteChangeKey)
            if !debug {
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                    containerIdentifier: "iCloud.engineering.lutris.fleetbox"
                )
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? container.viewContext.setQueryGenerationFrom(.current)
        let coordinator = container.persistentStoreCoordinator
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                SentrySDK.capture(error: error)
            } else if !inMemory {
                let indexer = VehicleSpotlightDelegate(forStoreWith: description, coordinator: coordinator)
                indexer.startSpotlightIndexing()
            }
        })
    }
}
