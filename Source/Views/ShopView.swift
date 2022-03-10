//
//  ShopView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var shop: Shop
    
    var body: some View {
        Text(shop.name ?? "Unknown shop")
            .navigationTitle(shop.name ?? "Shop")
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            ShopView(shop: PersistenceController.preview.fixtures.shop)
        }
    }
}
