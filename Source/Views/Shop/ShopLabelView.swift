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

struct ShopLabelView: View {
    @ObservedObject var shop: Shop

    private var location: Text {
        if let location = shop.location?.normalized {
            return Text("\n\(location)").foregroundColor(.secondary)
        } else {
            return Text("")
        }
    }

    var body: some View {
        Text(shop.name ?? "Unknown shop").foregroundColor(.primary) +
            location
    }
}
