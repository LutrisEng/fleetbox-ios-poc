//  SPDX-License-Identifier: GPL-3.0-or-later
//  Fleetbox, a tool for managing vehicle maintenance logs
//  Copyright (C) 2022 Lutris, Inc
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI
import Sentry
import FilePicker

struct LogItemView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var logItem: LogItem

    enum NavigationState: Hashable {
        case addLineItem, addShop, addAttachment
    }

    @State private var navigationState: NavigationState?

    func createLineItem(type: LineItemType) -> LineItem {
        withAnimation {
            LineItem(context: viewContext, logItem: logItem, type: type)
        }
    }

    @State private var addingAttachments: Bool = false

    var body: some View {
        VStack {
            Form {
                FleetboxTextField(
                        value: $logItem.displayName,
                        name: "Name",
                        example: "10k service"
                )
                if editable {
                    DatePicker(
                            "Performed",
                            selection: convertToNonNilBinding(date: $logItem.performedAt),
                            in: ...Date.now,
                            displayedComponents: logItem.includeTime ? [.date, .hourAndMinute] : [.date]
                    )
                    Toggle("Include time", isOn: $logItem.includeTime)
                } else if let formattedDate = logItem.formattedDate {
                    FormLinkLabel(title: "Performed", value: formattedDate)
                }
                if let vehicle = logItem.vehicle {
                    Section(header: Text("Vehicle")) {
                        NavigationLink(vehicle.displayNameWithFallback) {
                            VehicleView(vehicle: vehicle)
                        }
                    }
                }
                Section(header: Text("Shop")) {
                    if let shop = logItem.shop {
                        NavigationLink("Performed by \(shop.name ?? "a shop")") {
                            ShopView(shop: shop)
                        }
                        if editable {
                            Button("Remove shop") {
                                logItem.shop = nil
                            }
                        }
                    } else {
                        Text("Performed by owner")
                        if editable {
                            NavigationLink("Add shop") {
                                ShopPickerView(selected: logItem.shop) {
                                    logItem.shop = $0
                                }
                                .navigationTitle("Add shop")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }
                }
                Section(header: Text("Odometer reading")) {
                    if let odometerReading = logItem.odometerReading {
                        FleetboxTextField(
                            value: Binding(
                                get: { odometerReading.reading },
                                set: { odometerReading.reading = $0 }
                            ),
                            name: "At service",
                            example: 0
                        )
                        .unit("miles")
                        if editable {
                            Button("Remove odometer reading") {
                                withAnimation {
                                    viewContext.delete(odometerReading)
                                }
                            }
                        }
                    } else if editable {
                        Button("Add odometer reading") {
                            _ = OdometerReading(context: viewContext, logItem: logItem)
                        }
                    }
                }
                Section(header: Text("Line items")) {
                    let lineItems = logItem.lineItems.sorted
                    if lineItems.isEmpty {
                        Text("No line items")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(lineItems) { lineItem in
                            if editable {
                                NavigationLink(destination: LineItemView(lineItem: lineItem)) {
                                    LineItemLabelView(lineItem: lineItem).details.padding([.top, .bottom], 10)
                                }
                            } else {
                                LineItemLabelView(lineItem: lineItem).details.padding([.top, .bottom], 10)
                            }
                        }
                    }
                    if editable {
                        NavigationLink(
                            destination: {
                                LineItemTypePickerView {
                                    _ = createLineItem(type: $0)
                                }
                                .navigationTitle("Add line item")
                                .navigationBarTitleDisplayMode(.inline)
                            },
                            label: {
                                Text("\(Image(systemName: "plus")) Add line item")
                                    .foregroundColor(.accentColor)
                            }
                        )
                    }
                }
                Section(header: Text("Attachments")) {
                    let attachments = logItem.attachments.sorted.normalize()
                    ForEachObjects(attachments) { attachment in
                        NavigationLink(
                            destination: {
                                AttachmentView(attachment: attachment)
                            },
                            label: {
                                AttachmentLabelView(attachment: attachment)
                            }
                        )
                    }
                    if addingAttachments {
                        ProgressView()
                    }
                    if editable {
                        FilePicker(
                            types: [.data],
                            allowMultiple: true,
                            title: "Add attachment",
                            onPicked: addAttachments
                        )
                    }
                }
            }
        }
        .modifier(SaveOnLeave())
        .modifier(WithEditButton())
        .navigationTitle("Log item")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addAttachments(urls: [URL]) {
        withAnimation {
            addingAttachments = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let attachments = urls.compactMap { url -> Attachment? in
                do {
                    let attachment = Attachment(context: viewContext)
                    try attachment.importFile(url: url)
                    return attachment
                } catch {
                    SentrySDK.capture(error: error)
                    return nil
                }
            }
            DispatchQueue.main.async {
                withAnimation {
                    var sortOrder = (logItem.attachments.map(\.sortOrder).max() ?? 0) + 1
                    for attachment in attachments {
                        attachment.logItem = logItem
                        attachment.sortOrder = sortOrder
                        sortOrder += 1
                    }
                    addingAttachments = false
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct LogItemView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            LogItemView(logItem: fixtures.logItem)
        }
    }
}
#endif
