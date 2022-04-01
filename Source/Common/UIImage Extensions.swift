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

import UIKit
import CoreGraphics

// https://stackoverflow.com/a/61830766/2329281
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

extension UIImage {
    func resize(maxWidth: CGFloat) -> UIImage? {
        if maxWidth > size.width {
            return self
        }
        let aspectRatio = size.height / size.width
        let height = (aspectRatio * maxWidth).rounded()
        let newSize = CGSize(width: maxWidth, height: height)

        UIGraphicsBeginImageContextWithOptions(
            newSize, false, self.scale
        )
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // https://stackoverflow.com/a/61830766/2329281
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
    var heicData: Data? { heicData() }
    func heicData(compressionQuality: CGFloat = 1) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(
                mutableData,
                "public.heic" as CFString,
                1,
                nil
            ),
            let cgImage = cgImage
        else { return nil }
        CGImageDestinationAddImage(
            destination,
            cgImage,
            [
                kCGImageDestinationLossyCompressionQuality: compressionQuality,
                kCGImagePropertyOrientation: cgImageOrientation.rawValue
            ] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
