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
        
        init(viewContext: NSManagedObjectContext) {
            vehicle = Vehicle(context: viewContext)
            vehicle.year = 2022
            vehicle.make = "BMW"
            vehicle.model = "M340i"
            vehicle.vin = "3MW5U7J09N8C40580"
            let factory = Shop(context: viewContext)
            factory.name = "BMW"
            let factoryLogItem = LogItem(context: viewContext)
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
            try! factoryTireLineItem.setFieldValue("tireSet", value: tireSet)
            shop = Shop(context: viewContext)
            shop.name = "BMW of West Houston"
            logItem = LogItem(context: viewContext)
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
            try! lineItem.setFieldValue("viscosity", value: "0W-20")
            try! lineItem.setFieldValue("brand", value: "BMW")
            try! lineItem.setFieldValue("partNumber", value: "83-21-2-463-673")
            let secondLineItem = LineItem(context: viewContext, logItem: logItem)
            secondLineItem.typeId = "engineOilFilterChange"
            try! secondLineItem.setFieldValue("brand", value: "BMW")
            try! secondLineItem.setFieldValue("partNumber", value: "11-42-8-583-898")
            let laterOdometerReading = OdometerReading(context: viewContext)
            laterOdometerReading.reading = 6871
            laterOdometerReading.at = Date(timeIntervalSince1970: 1646550183)
            laterOdometerReading.vehicle = vehicle
            try! viewContext.save()
        }
    }
    
    struct Preview {
        let controller: PersistenceController
        let viewContext: NSManagedObjectContext
        let fixtures: Fixtures
        
        init() {
            controller = PersistenceController(inMemory: true)
            viewContext = controller.container.viewContext
            fixtures = Fixtures(viewContext: viewContext)
        }
    }

    static var preview: Preview = Preview()

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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else if (!inMemory) {
                let indexer = VehicleSpotlightDelegate(forStoreWith: description, coordinator: coordinator)
                indexer.startSpotlightIndexing()
            }
        })
    }
}
