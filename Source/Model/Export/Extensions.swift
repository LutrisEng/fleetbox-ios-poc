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

extension Fleetbox_Export_ExportEnvelope {
    init(vehicle: Vehicle) {
        let tmpl = ExportEnvelopeTemplate(vehicle: vehicle)
        self.vehicle = Fleetbox_Export_Vehicle(envelope: tmpl, vehicle: vehicle)
        shops = tmpl.shops.map { Fleetbox_Export_Shop(shop: $0) }
        tireSets = tmpl.tireSets.map { Fleetbox_Export_TireSet(tireSet: $0) }
    }
}

extension Fleetbox_Export_BackupExport {
    init(context: NSManagedObjectContext) throws {
        let tmpl = try ExportEnvelopeTemplate(allFromContext: context)
        let vehiclesFetchRequest = NSFetchRequest<Vehicle>(entityName: "Vehicle")
        vehicles = try context.fetch(vehiclesFetchRequest)
            .map { Fleetbox_Export_Vehicle(envelope: tmpl, vehicle: $0) }
        shops = tmpl.shops.map { Fleetbox_Export_Shop(shop: $0) }
        tireSets = tmpl.tireSets.map { Fleetbox_Export_TireSet(tireSet: $0) }
    }

    func importBackup(context: NSManagedObjectContext) throws {
        let tmpl = ExportEnvelopeTemplate(context: context, backup: self)
        for vehicle in vehicles {
            _ = vehicle.importVehicle(context: context, envelope: tmpl)
        }
    }
}

extension Fleetbox_Export_Shop {
    init(shop: Shop) {
        if let name = shop.name {
            self.name = name
        }
    }

    func importShop(context: NSManagedObjectContext) -> Shop {
        let shop = Shop(context: context)
        shop.name = name
        return shop
    }
}

extension Fleetbox_Export_TireSet {
    init(tireSet: TireSet) {
        aspectRatio = Int32(tireSet.aspectRatio)
        if let construction = tireSet.construction {
            self.construction = construction
        }
        diameter = Int32(tireSet.diameter)
        loadIndex = Int32(tireSet.loadIndex)
        if let make = tireSet.make {
            self.make = make
        }
        if let model = tireSet.model {
            self.model = model
        }
        if let speedRating = tireSet.speedRating {
            self.speedRating = speedRating
        }
        if let displayName = tireSet.userDisplayName {
            self.displayName = displayName
        }
        if let vehicleType = tireSet.vehicleType {
            self.vehicleType = vehicleType
        }
        width = Int32(tireSet.width)
        if let tin = tireSet.tin {
            self.tin = tin
        }
        hidden = tireSet.hidden
        breakin = tireSet.breakin
        warranties = tireSet.warranties.map { Fleetbox_Export_Warranty(warranty: $0) }
        baseMiles = tireSet.baseMiles
    }

    func importTireSet(context: NSManagedObjectContext) -> TireSet {
        let tireSet = TireSet(context: context)
        tireSet.aspectRatio = Int16(aspectRatio)
        tireSet.construction = construction
        tireSet.diameter = Int16(diameter)
        tireSet.loadIndex = Int16(loadIndex)
        tireSet.make = make
        tireSet.model = model
        tireSet.speedRating = speedRating
        tireSet.userDisplayName = displayName
        tireSet.vehicleType = vehicleType
        tireSet.width = Int16(width)
        tireSet.tin = tin
        tireSet.hidden = hidden
        tireSet.breakin = breakin
        for warranty in warranties {
            _ = warranty.importWarranty(context: context, underlying: tireSet)
        }
        tireSet.baseMiles = baseMiles
        return tireSet
    }
}

extension Fleetbox_Export_Vehicle {
    init(envelope: ExportEnvelopeTemplate, vehicle: Vehicle) {
        if let displayName = vehicle.displayName {
            self.displayName = displayName
        }
        if let make = vehicle.make {
            self.make = make
        }
        if let model = vehicle.model {
            self.model = model
        }
        if let vin = vehicle.vin {
            self.vin = vin
        }
        year = vehicle.year
        if let imageData = vehicle.imageData {
            self.image = imageData
        }
        logItems = vehicle.logItems.map {
            Fleetbox_Export_LogItem(envelope: envelope, logItem: $0)
        }
        freeOdometerReadings = vehicle.odometerReadings.chrono
                .filter({ $0.logItem == nil })
                .map {
                    Fleetbox_Export_OdometerReading(odometerReading: $0)
                }
        breakin = vehicle.breakin
        warranties = vehicle.warranties.map { Fleetbox_Export_Warranty(warranty: $0) }
        milesPerYear = vehicle.milesPerYear
    }

    func importVehicle(context: NSManagedObjectContext, envelope: ExportEnvelopeTemplate) -> Vehicle {
        let vehicle = Vehicle(context: context)
        vehicle.displayName = displayName
        vehicle.make = make
        vehicle.model = model
        vehicle.vin = vin
        vehicle.year = year
        if hasImage {
            vehicle.imageData = image
        }
        for logItem in logItems {
            _ = logItem.importLogItem(
                context: context,
                envelope: envelope,
                vehicle: vehicle
            )
        }
        for odometerReading in freeOdometerReadings {
            _ = odometerReading.importOdometerReading(context: context, vehicle: vehicle)
        }
        vehicle.breakin = breakin
        for warranty in warranties {
            _ = warranty.importWarranty(context: context, underlying: vehicle)
        }
        vehicle.milesPerYear = milesPerYear
        return vehicle
    }
}

extension Fleetbox_Export_OdometerReading {
    init(odometerReading: OdometerReading) {
        if let performedAt = odometerReading.at {
            self.performedAt = Int64(performedAt.timeIntervalSince1970)
        }
        self.reading = odometerReading.reading
    }

    func importOdometerReading(context: NSManagedObjectContext, vehicle: Vehicle) -> OdometerReading {
        let odometerReading = OdometerReading(context: context)
        odometerReading.vehicle = vehicle
        if hasPerformedAt {
            odometerReading.at = Date(timeIntervalSince1970: TimeInterval(performedAt))
        }
        odometerReading.reading = reading
        return odometerReading
    }
}

extension Fleetbox_Export_LogItem {
    init(envelope: ExportEnvelopeTemplate, logItem: LogItem) {
        if let displayName = logItem.displayName {
            self.displayName = displayName
        }
        if let performedAt = logItem.performedAt {
            self.performedAt = Int64(performedAt.timeIntervalSince1970)
        }
        lineItems = logItem.lineItems.map {
            Fleetbox_Export_LineItem(envelope: envelope, lineItem: $0)
        }
        if let odometerReading = logItem.odometerReading {
            self.odometerReading = odometerReading.reading
        }
        if let shop = logItem.shop {
            if let idx = envelope.shops.firstIndex(of: shop) {
                self.shop = Int64(idx)
            } else {
                self.shop = Int64(envelope.shops.count)
                envelope.shops.append(shop)
            }
        }
        attachments = logItem.attachments.map {
            Fleetbox_Export_Attachment(attachment: $0)
        }
    }

    func importLogItem(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        vehicle: Vehicle
    ) -> LogItem {
        let logItem = LogItem(context: context)
        logItem.vehicle = vehicle
        logItem.displayName = displayName
        if hasPerformedAt {
            logItem.performedAt = Date(timeIntervalSince1970: TimeInterval(performedAt))
        }
        for (index, lineItem) in lineItems.enumerated() {
            _ = lineItem.importLineItem(
                context: context,
                envelope: envelope,
                index: index,
                logItem: logItem
            )
        }
        if hasOdometerReading {
            let odometerReading = OdometerReading(context: context, logItem: logItem)
            odometerReading.reading = Int64(self.odometerReading)
        }
        if hasShop {
            logItem.shop = envelope.shops[Int(shop)]
        }
        for (index, attachment) in attachments.enumerated() {
            let obj = attachment.importAttachment(context: context, index: index)
            obj.logItem = logItem

        }
        return logItem
    }
}

extension Fleetbox_Export_Attachment {
    init(attachment: Attachment) {
        if let filename = attachment.fileName {
            self.filename = filename
        }
        if let contents = attachment.fileContents {
            self.contents = contents
        }
    }

    func importAttachment(context: NSManagedObjectContext, index: Int) -> Attachment {
        let attachment = Attachment(context: context)
        attachment.sortOrder = Int16(index)
        attachment.fileName = filename
        if hasContents {
            attachment.fileContents = contents
        }
        return attachment
    }
}

extension Fleetbox_Export_LineItem {
    init(envelope: ExportEnvelopeTemplate, lineItem: LineItem) {
        if let notes = lineItem.notes {
            self.notes = notes
        }
        typeID = lineItem.typeId ?? "misc"
        fields = lineItem.fields.map {
            Fleetbox_Export_LineItemField(envelope: envelope, lineItemField: $0)
        }
    }

    func importLineItem(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        index: Int,
        logItem: LogItem
    ) -> LineItem {
        let lineItem = LineItem(context: context, logItem: logItem)
        lineItem.notes = notes
        lineItem.sortOrder = Int16(index)
        lineItem.typeId = typeID
        for field in fields {
            _ = field.importLineItemField(
                context: context,
                envelope: envelope,
                lineItem: lineItem
            )
        }
        return lineItem
    }
}

extension Fleetbox_Export_LineItemField {
    init(envelope: ExportEnvelopeTemplate, lineItemField: LineItemField) {
        if let typeID = lineItemField.typeId {
            self.typeID = typeID
        }
        if let stringValue = lineItemField.stringValue {
            self.stringValue = stringValue
        }
        if let tireSet = lineItemField.tireSetValue {
            if let idx = envelope.tireSets.firstIndex(of: tireSet) {
                tireSetValue = Int64(idx)
            } else {
                tireSetValue = Int64(envelope.tireSets.count)
                envelope.tireSets.append(tireSet)
            }
        }
        integerValue = lineItemField.integerValue
    }

    func importLineItemField(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        lineItem: LineItem
    ) -> LineItemField {
        let field = LineItemField(context: context)
        field.lineItem = lineItem
        field.typeId = typeID
        field.stringValue = stringValue
        if hasTireSetValue {
            field.tireSetValue = envelope.tireSets[Int(tireSetValue)]
        }
        if hasIntegerValue {
            field.integerValue = integerValue
        }
        return field
    }
}

extension Fleetbox_Export_Warranty {
    init(warranty: Warranty) {
        title = warranty.title ?? ""
        miles = warranty.miles
        months = warranty.months
    }

    func importWarranty(context: NSManagedObjectContext, underlying: Warranty.Underlying) -> Warranty {
        let warranty = Warranty(context: context, underlying: underlying)
        warranty.title = title
        warranty.miles = miles
        warranty.months = months
        return warranty
    }
}
