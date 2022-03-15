//
//  ExportableShop.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

import Foundation
import CoreData

struct ExportableShop: Codable {
    let name: String?
    let sortOrder: Int16

    init(shop: Shop) {
        name = shop.name
        sortOrder = shop.sortOrder
    }

    func importShop(context: NSManagedObjectContext) -> Shop {
        let shop = Shop(context: context)
        shop.name = name
        shop.sortOrder = sortOrder
        return shop
    }
}
