//
//  LineItemView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/8/22.
//

import SwiftUI

struct LineItemView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var lineItem: LineItem

    var body: some View {
        Form {
            ForEach(lineItem.fields) { field in
                EditLineItemFieldView(field: field)
            }
        }
                .navigationTitle(lineItem.type?.displayName ?? "Unknown Line Item")
                .onAppear {
                    viewContext.perform {
                        lineItem.createMissingFields()
                    }
                }
    }
}

struct LineItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            LineItemView(lineItem: fixtures.lineItem)
        }
    }
}
