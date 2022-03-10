//
//  VINDecoder.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/2/22.
//

import Foundation
import Alamofire

func decodeVIN(_ vin: String) async throws -> VINDecoderResult {
    let url = "https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/\(vin)?format=json"
    let response = try await AF.request(url).serializingDecodable(VINDecoderResponse.self).value
    return response.toResult()
}
