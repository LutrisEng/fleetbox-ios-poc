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

    @ObservedObject var logItem: LogItem

    enum NavigationState: Hashable {
        case addLineItem, addShop, addAttachment
    }

    @State private var navigationState: NavigationState?

    func createLineItem() -> LineItem {
        LineItem(context: viewContext, logItem: logItem)
    }

    var body: some View {
        VStack {
            Form {
                FleetboxTextField(
                        value: $logItem.displayName,
                        name: nil,
                        example: "Display name"
                )
                DatePicker(
                        "Performed",
                        selection: convertToNonNilBinding(date: $logItem.performedAt),
                        displayedComponents: [.date]
                )
                Section(header: Text("Shop")) {
                    if let shop = logItem.shop {
                        NavigationLink("Performed by \(shop.name ?? "a shop")") {
                            ShopView(shop: shop)
                        }
                        Button("Remove shop") {
                            logItem.shop = nil
                        }
                    } else {
                        Text("Performed by owner")
                        NavigationLink("Add shop") {
                            ShopPickerView(selected: logItem.shop) {
                                logItem.shop = $0
                                ignoreErrors {
                                    try viewContext.save()
                                }
                            }
                            .navigationTitle("Add shop")
                            .navigationBarTitleDisplayMode(.inline)
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
                                                let filtered = value.filter {
                                                    $0.isNumber
                                                }
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
                            LineItemLabelView(lineItem: lineItem).details.padding([.top, .bottom], 10)
                        }
                    }
                            .onDelete { offsets in
                                withAnimation {
                                    offsets.map {
                                                lineItems[$0]
                                            }
                                            .forEach(viewContext.delete)
                                    ignoreErrors {
                                        try viewContext.save()
                                    }
                                }
                            }
                    NavigationLink("Add line item") {
                        LineItemTypePickerView {
                            let lineItem = createLineItem()
                            lineItem.type = $0
                            ignoreErrors {
                                try viewContext.save()
                            }
                        }
                        .navigationTitle("Add line item")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Section(header: Text("Attachments")) {
                    ForEach(logItem.attachments) { attachment in
                        Text(attachment.fileName ?? "Attachment")
                    }
                    NavigationLink("Add attachment", tag: NavigationState.addAttachment, selection: $navigationState) {
                        Text("Add attachment")
                    }
                }
            }
        }
                .navigationTitle("Log item")
    }
}

struct LogItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            LogItemView(logItem: fixtures.logItem)
        }
    }
}
