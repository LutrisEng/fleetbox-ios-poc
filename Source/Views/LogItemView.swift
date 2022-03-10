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
    
    @State private var newLineItemSheetPresented = false
    
    func createLineItem() -> LineItem {
        LineItem(context: viewContext, logItem: logItem)
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Shop")) {
                    if let shop = logItem.shop {
                        NavigationLink("Performed by \(shop.name ?? "a shop")") {
                            ShopView(shop: shop)
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
                        HStack {
                            TextField(
                                "Odometer reading at time of service",
                                text: Binding(
                                    get: {
                                        String(odometerReading.reading)
                                    },
                                    set: { value in
                                        let filtered = value.filter { $0.isNumber }
                                        odometerReading.reading = Int64(filtered) ?? 0
                                        ignoreErrors {
                                            try viewContext.save()
                                        }
                                    }
                                )
                            )
                                .keyboardType(.decimalPad)
                            Spacer()
                            Text("miles")
                        }
                        Button("Remove odometer reading") {
                            viewContext.delete(odometerReading)
                        }
                    } else {
                        Button("Add odometer reading") {
                            _ = OdometerReading(context: viewContext, logItem: logItem)
                            ignoreErrors {
                                try viewContext.save()
                            }
                        }
                    }
                }
                Section(header: Text("Line items")) {
                    let lineItems = logItem.lineItems
                    ForEach(Array(lineItems)) { lineItem in
                        NavigationLink(destination: LineItemView(lineItem: lineItem)) {
                            LineItemLabelView(lineItem: lineItem).details().padding([.top, .bottom], 10)
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
        .navigationTitle(logItem.displayName ?? logItem.formattedDate ?? "Log item")
            .sheet(isPresented: $newLineItemSheetPresented) {
                List(lineItemTypes.hierarchyItems, children: \.children) { item in
                    switch item {
                    case .type(let t):
                        Button(action: {
                            let lineItem = createLineItem()
                            lineItem.type = t
                            ignoreErrors {
                                try viewContext.save()
                            }
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
        PreviewWrapper {
            LogItemView(logItem: PersistenceController.preview.fixtures.logItem)
        }
    }
}
