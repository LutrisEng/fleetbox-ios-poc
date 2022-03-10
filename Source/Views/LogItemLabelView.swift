//
//  LogItemLabel.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import SwiftUI

struct LogItemLabelView: View {
    @ObservedObject var logItem: LogItem
    
    var body: some View {
        VStack {
            Text(logItem.formattedDate ?? "Log item")
                .font(.body.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(logItem.lineItems) { lineItem in
                LineItemLabelView(lineItem: lineItem).mini
            }
        }
    }
}

struct LogItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        return List {
            LogItemLabelView(logItem: PersistenceController.preview.fixtures.logItem)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
