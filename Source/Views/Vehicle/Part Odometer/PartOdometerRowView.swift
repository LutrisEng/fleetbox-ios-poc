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

struct PartOdometerRowView: View {
    let name: String
    let milesSince: Int64?
    let timeSince: TimeInterval?

    static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month, .weekOfMonth, .day]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.includesApproximationPhrase = true
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    var milesSinceText: Text {
        if let milesSince = milesSince {
            return Text("About \(milesSince) miles")
        } else {
            return Text("")
        }
    }

    var separator: Text {
        if milesSince != nil && timeSince != nil {
            return Text("\n")
        } else {
            return Text("")
        }
    }

    var timeSinceText: Text {
        if let timeSince = timeSince,
           let str = PartOdometerRowView.formatter.string(from: timeSince) {
            return Text("\(str) old")
        } else {
            return Text("")
        }
    }

    var body: some View {
        HStack {
            Text(LocalizedStringKey(name))
            Spacer()
            (milesSinceText + separator + timeSinceText)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}

struct PartOdometerRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PartOdometerRowView(name: "Vehicle", milesSince: 1000, timeSince: nil)
        }
    }
}
