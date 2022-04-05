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
    let milesLife: Int?
    let monthsLife: Int?

    init(name: String,
         milesSince: Int64? = nil, timeSince: TimeInterval? = nil,
         milesLife: Int? = nil, monthsLife: Int? = nil) {
        self.name = name
        self.milesSince = milesSince
        self.timeSince = timeSince
        self.milesLife = milesLife
        self.monthsLife = monthsLife
    }

    var formattedLife: Text {
        if let milesLife = milesLife, let monthsLife = monthsLife {
            return (
                Text("\nLife of \(Formatter.format(number: milesLife)) miles\n") +
                Text("or \(Formatter.format(monthsLabel: monthsLife))")
            )
        } else if let milesLife = milesLife {
            return Text("\nLife of \(Formatter.format(number: milesLife)) miles")
        } else if let monthsLife = monthsLife {
            return Text("\nLife of \(Formatter.format(monthsLabel: monthsLife))")
        } else {
            return Text("")
        }
    }

    var formattedMilesSince: Text {
        if let milesSince = milesSince {
            return Text("About \(Formatter.format(number: milesSince)) miles")
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

    var formattedTimeSince: Text {
        if let timeSince = timeSince {
            return Text("\(Formatter.format(durationLabel: timeSince)) old")
        } else {
            return Text("")
        }
    }

    var milesProgress: Double? {
        if let milesSince = milesSince, let milesLife = milesLife {
            return Double(milesSince) / Double(milesLife)
        } else {
            return nil
        }
    }

    var monthsProgress: Double? {
        if let timeSince = timeSince, let monthsLife = monthsLife {
            let monthsSince = toMonths(interval: timeSince)
            return monthsSince / Double(monthsLife)
        } else {
            return nil
        }
    }

    var progress: Double? {
        max(milesProgress, monthsProgress)
    }

    var progressColor: Color? {
        if let progress = progress {
            if progress > 1 {
                return .yellow
            } else {
                return .green
            }
        } else {
            return nil
        }
    }

    var body: some View {
        FormLinkLabel(
            title: Text(name) + formattedLife.foregroundColor(.secondary).font(.caption),
            value: formattedMilesSince + separator + formattedTimeSince
        )
        .progress(progress)
        .progressColor(progressColor)
    }
}

struct PartOdometerRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PartOdometerRowView(name: "Vehicle", milesSince: 1000, timeSince: nil)
        }
    }
}
