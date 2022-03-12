//
//  ShopPickerView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct ShopPickerView: View {
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Shop.sortOrder, ascending: true)],
            animation: .default)
    private var shops: FetchedResults<Shop>

    let selected: Shop?
    let action: (Shop) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(shops, id: \.self) { shop in
                    Button(action: { action(shop) }, label: {
                        HStack {
                            Text(shop.name ?? "Unknown shop")
                                    .foregroundColor(.primary)
                            if selected == shop {
                                Spacer()
                                Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                            }
                        }
                    })
                }
            }
                    .navigationTitle("Shops")
        }
    }
}

struct ShopPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            ShopPickerView(selected: nil) {
                print($0.name ?? "Unknown shop")
            }
        }
    }
}
