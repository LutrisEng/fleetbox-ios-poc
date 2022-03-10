//
//  LogItemView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/5/22.
//

import SwiftUI
import Sentry

struct LogItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var logItem: LogItem
    
    @State private var odometerReadingSheetPresented = false
    @State private var odometerReadingSheetOdometerReading: OdometerReading? = nil
    
    func createOdometerReading() -> OdometerReading {
        let reading = OdometerReading(context: viewContext)
        reading.logItem = logItem
        reading.vehicle = logItem.vehicle
        reading.at = Date.now
        return reading
    }
    
    @State private var newLineItemSheetPresented = false
    
    func createLineItem() -> LineItem {
        LineItem(context: viewContext, logItem: logItem)
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Shop")) {
                    if let shop = logItem.shop {
                        NavigationLink(shop.name ?? "Performed by shop") {
                            Text("This is a page for a shop, k?")
                        }
                        Button ("Remove shop") {
                            logItem.shop = nil
                        }
                    } else {
                        Text("Performed by owner")
                        Button("Add shop") {
                            
                        }
                    }
                }
                Section(header: Text("Odometer reading")) {
                    if let odometerReading = logItem.odometerReading {
                        Button("\(odometerReading.reading) miles") {
                            odometerReadingSheetPresented = true
                            odometerReadingSheetOdometerReading = odometerReading
                        }
                    } else {
                        Button("Add odometer reading") {
                            odometerReadingSheetPresented = true
                            odometerReadingSheetOdometerReading = createOdometerReading()
                        }
                    }
                }
                Section(header: Text("Line items")) {
                    let lineItems = logItem.lineItems
                    ForEach(Array(lineItems)) { lineItem in
                        NavigationLink(destination: LineItemView(lineItem: lineItem)) {
                            LineItemLabelView(lineItem: lineItem).details()
                        }
                    }.onDelete { offsets in
                        withAnimation {
                            offsets.map { lineItems[$0] }.forEach(viewContext.delete)

                            do {
                                try viewContext.save()
                            } catch {
                                SentrySDK.capture(error: error)
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    }
                    Button("Add line item") {
                        newLineItemSheetPresented = true
                    }
                }
            }
        }
            .navigationTitle(logItem.formattedDate ?? "Log item")
            .sheet(isPresented: $odometerReadingSheetPresented, onDismiss: {
                try? viewContext.save()
            }) {
                if let reading = odometerReadingSheetOdometerReading {
                    OdometerReadingView(odometerReading: reading) {
                        odometerReadingSheetPresented = false
                        try? viewContext.save()
                    }
                }
            }
            .sheet(isPresented: $newLineItemSheetPresented) {
                List(lineItemTypes.hierarchyItems, children: \.children) { item in
                    switch item {
                    case .type(let t):
                        Button(action: {
                            let lineItem = createLineItem()
                            lineItem.type = t
                            try? viewContext.save()
                            newLineItemSheetPresented = false
                        }) {
                            LineItemTypeLabelView(type: t)
                        }
                    case .category(let c):
                        Text(c.displayName)
                    }
                }.navigationTitle("New line item")
            }
    }
}

struct LogItemView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            LogItemView(logItem: PersistenceController.preview.fixtures.logItem)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
