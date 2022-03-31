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

import Foundation

func temporaryFileURL(fileName: String? = nil, fileExtension: String? = nil) -> URL {
    let temporaryFileName = fileName ?? ProcessInfo().globallyUniqueString
    let temporaryFileExtension: String = {
        if let fileExtension = fileExtension {
            return ".\(fileExtension)"
        } else {
            return ""
        }
    }()
    return FileManager.default.temporaryDirectory.appendingPathComponent(
        temporaryFileName + temporaryFileExtension
    )
}

extension FileManager {
    // https://stackoverflow.com/a/48008323/2329281
    func clearTmpDirectory() {
        ignoreErrors {
            let url = temporaryDirectory
            let contents = try contentsOfDirectory(atPath: url.path)
            contents.forEach { file in
                ignoreErrors {
                    let fileUrl = url.appendingPathComponent(file)
                    try removeItem(atPath: fileUrl.path)
                }
            }
        }
    }
}
