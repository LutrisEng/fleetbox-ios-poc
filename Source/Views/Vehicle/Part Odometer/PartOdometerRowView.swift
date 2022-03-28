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

    var formattedMilesSince: String {
        if let milesSince = milesSince {
            return "About \(Formatter.format(number: milesSince)) miles"
        } else {
            return ""
        }
    }

    var separator: String {
        if milesSince != nil && timeSince != nil {
            return "\n"
        } else {
            return ""
        }
    }

    var formattedTimeSince: String {
        if let timeSince = timeSince {
            return "\(Formatter.format(durationLabel: timeSince)) old"
        } else {
            return ""
        }
    }

    var body: some View {
        FormLinkLabel(title: name, value: formattedMilesSince + separator + formattedTimeSince)
    }
}

struct PartOdometerRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PartOdometerRowView(name: "Vehicle", milesSince: 1000, timeSince: nil)
        }
    }
}
