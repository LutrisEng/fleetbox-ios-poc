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
        Form {
            FleetboxTextField(value: $shop.name, name: "Name", example: "Quick Lube of Anytown USA")
            Section(header: Text("Actions")) {
                Button("Merge with other shop") {
                }
            }
        }
                .navigationTitle("Shop")
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            ShopView(shop: fixtures.shop)
        }
    }
}
