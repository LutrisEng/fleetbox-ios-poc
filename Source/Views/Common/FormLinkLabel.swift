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

protocol Textable {
    var text: Text { get }
}
extension Text: Textable {
    var text: Text {
        self
    }
}
extension String: Textable {
    var text: Text {
        Text(self)
    }
}
extension LocalizedStringKey: Textable {
    var text: Text {
        Text(self)
    }
}
extension Int64: Textable {
    var text: Text {
        Text(Formatter.format(number: self))
    }
}

struct FormLinkLabel: View {
    let title: Text
    let value: Text

    private var _titleCaption: Text?
    private var _caption: Text?
    private var _badge: Badge?
    private var _progress: Double?
    private var _progressColor: Color?
    private var _allowNewline: Bool = true

    init<Title: Textable, Value: Textable>(title: Title, value: Value) {
        self.title = title.text
        self.value = value.text
    }

    func titleCaption<Caption: Textable>(_ caption: Caption?) -> Self {
        var view = self
        if let caption = caption {
            view._titleCaption = caption.text.font(.caption).foregroundColor(.secondary)
        } else {
            view._titleCaption = nil
        }
        return view
    }

    func caption<Caption: Textable>(_ caption: Caption?) -> Self {
        var view = self
        if let caption = caption {
            view._caption = caption.text.font(.caption)
        } else {
            view._caption = nil
        }
        return view
    }

    func progress(_ progress: Double?) -> Self {
        var view = self
        view._progress = progress
        return view
    }

    func progressColor(_ color: Color?) -> Self {
        var view = self
        view._progressColor = color
        return view
    }

    func badge(_ badge: Badge?) -> Self {
        var view = self
        view._badge = badge
        return view
    }

    func allowNewline(_ allowNewline: Bool = true) -> Self {
        var view = self
        view._allowNewline = allowNewline
        return view
    }

    var maybeTitleCaption: Text {
        if let titleCaption = _titleCaption {
            return Text("\n") + titleCaption
        } else {
            return Text("")
        }
    }

    var maybeCaption: Text {
        if let caption = _caption {
            return Text("\n") + caption
        } else {
            return Text("")
        }
    }

    @ViewBuilder
    var label: some View {
        HStack {
            (title + maybeTitleCaption)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            (value + maybeCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(_allowNewline ? nil : 1)
                .fixedSize(horizontal: false, vertical: true)
            if let badge = _badge {
                badge
            }
        }
    }

    var body: some View {
        if let progress = _progress {
            VStack {
                label
                ProgressView(value: progress)
                    .tint(_progressColor)
            }
        } else {
            label
        }
    }
}
