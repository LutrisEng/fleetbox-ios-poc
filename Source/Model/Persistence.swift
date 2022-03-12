//
//  Persistence.swift
//  Shared
//
//  Created by Piper McCorkle on 2/28/22.
//

import CoreData
import Sentry

struct PersistenceController {
    static let shared = PersistenceController()

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
            let factoryTireLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryTireLineItem.typeId = "mountedTires"
            try factoryTireLineItem.setFieldValue("tireSet", value: tireSet)
            let factoryOilLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryOilLineItem.typeId = "engineOilChange"
            let factoryOilFilterLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryOilFilterLineItem.typeId = "engineOilFilterChange"
            let factoryTransmissionFluidLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryTransmissionFluidLineItem.typeId = "transmissionFluidChange"
            let factoryTransmissionFluidFilterLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryTransmissionFluidFilterLineItem.typeId = "transmissionFluidFilterChange"
            let factoryCoolantLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryCoolantLineItem.typeId = "coolantChange"
            let factoryBrakeFluidLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryBrakeFluidLineItem.typeId = "brakeFluidChange"
            let factoryEngineAirFilterLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryEngineAirFilterLineItem.typeId = "engineAirFilterChange"
            let factoryCabinAirFilterLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryCabinAirFilterLineItem.typeId = "cabinAirFilterChange"
            let factoryBatteryLineItem = LineItem(context: viewContext, logItem: factoryLogItem)
            factoryBatteryLineItem.typeId = "batteryReplacement"
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
            lineItem = LineItem(context: viewContext, logItem: logItem)
            lineItem.typeId = "engineOilChange"
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

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Fleetbox")
        let description = container.persistentStoreDescriptions.first
        if inMemory {
            description!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            description?.type = NSSQLiteStoreType
            description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
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
