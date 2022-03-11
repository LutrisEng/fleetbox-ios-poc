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
            ForEach(lineItem.allFields) { field in
                EditLineItemFieldView(field: field)
            }
        }
        .navigationTitle(lineItem.type?.displayName ?? "Unknown Line Item")
    }
}

struct LineItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            LineItemView(lineItem: PersistenceController.preview.fixtures.lineItem)
        }
    }
}
