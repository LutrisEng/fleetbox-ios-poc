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

struct WarrantyListingView: View {
    @ObservedObject var warranty: Warranty

    var value: LocalizedStringKey {
        if warranty.miles != 0 && warranty.months != 0 {
            return "\(warranty.miles) miles\nor \(warranty.months) months"
        } else if warranty.miles != 0 {
            return "\(warranty.miles) miles"
        } else if warranty.months != 0 {
            return "\(warranty.months) months"
        } else {
            return ""
        }
    }

    var caption: LocalizedStringKey? {
        if let percentage = warranty.percentage {
            let milesPercentage = warranty.milesPercentage
            let monthsPercentage = warranty.monthsPercentage
            if let milesPercentage = milesPercentage, let monthsPercentage = monthsPercentage {
                return "\(percentage) complete\n(\(milesPercentage) distance, \(monthsPercentage) time)"
            } else {
                return "\(percentage) complete"
            }
        } else {
            return nil
        }
    }

    @ViewBuilder
    var label: some View {
        VStack {
            FormLinkLabel(title: warranty.title ?? "Warranty", value: value)
                .badge(warranty.badge)
                .progress(warranty.progress)
                .titleCaption(caption)
        }
    }

    var body: some View {
        NavigationLink(destination: { WarrantyView(warranty: warranty) }, label: { label })
    }
}
