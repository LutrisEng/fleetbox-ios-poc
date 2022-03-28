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

struct LogItemLabelView: View {
    @ObservedObject var logItem: LogItem
    let showVehicle: Bool

    init(logItem: LogItem, showVehicle: Bool = false) {
        self.logItem = logItem
        self.showVehicle = showVehicle
    }

    var header: Text {
        var useNewline = false
        var text: Text = Text("")

        func append(_ newText: Text) {
            // swiftlint:disable:next shorthand_operator
            text = text + newText
        }
        func newline() -> Text {
            if useNewline {
                return Text("\n")
            } else {
                useNewline = true
                return Text("")
            }
        }
        func withNewline<T: Textable>(_ newText: T) -> Text {
            return newline() + newText.text
        }

        if showVehicle, let vehicle = logItem.vehicle {
            append(withNewline(vehicle.displayNameWithFallback).foregroundColor(.secondary))
        }
        if let odometerReading = logItem.odometerReading {
            append(withNewline("\(odometerReading.reading) miles").foregroundColor(.secondary))
        }
        if let displayName = logItem.displayName, !displayName.isEmpty {
            append(withNewline(displayName).font(.body.bold()))
            if let formattedDate = logItem.formattedDate {
                append(withNewline(formattedDate))
            }
        } else {
            append(withNewline(logItem.formattedDate ?? "Log item").font(.body.bold()))
        }
        if let shop = logItem.shop {
            append(withNewline("Performed by \(shop.name ?? "a shop")"))
        } else {
            append(withNewline("Performed by owner"))
        }

        return text
    }

    var body: some View {
        VStack {
            header
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            ForEach(logItem.lineItems.sorted) { lineItem in
                LineItemLabelView(lineItem: lineItem).mini
            }
        }
        .padding([.top, .bottom], 10)
    }
}

#if DEBUG
struct LogItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            List {
                LogItemLabelView(logItem: fixtures.logItem)
            }
        }
    }
}
#endif
