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

struct AttachmentLabelView: View {
    @ObservedObject var attachment: Attachment

    @ViewBuilder
    func badge<T: Textable>(text: T) -> some View {
        text.text
            .padding([.leading, .trailing], 10)
            .padding([.top, .bottom], 5)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(attachment.fileName ?? "Attachment")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                if let fileExtension = attachment.fileExtension {
                    badge(text: fileExtension.uppercased())
                }
                badge(text: Formatter.format(bytes: attachment.fileSize))
                Spacer()
            }
            .font(.caption)
        }
    }
}
