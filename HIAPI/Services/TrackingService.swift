//
//  TrackingService.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 2/6/19.
//  Copyright © 2019 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import APIManager

public final class TrackingService: EventService {
    public override static var baseURL: String {
        return super.baseURL + "track/"
    }

    public static func track(name: String, id: String) -> APIRequest<SimpleRequest> {
        var body = HTTPBody()
        body["eventName"] = name
        body["userId"] = id
        return APIRequest<SimpleRequest>(service: self, endpoint: "", body: body, method: .POST)
    }

    internal override static func hiValidate(statusCode: Int) throws {
        if ![200, 422, 500].contains(statusCode) {
            let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            throw APIRequestError.invalidHTTPReponse(code: statusCode, description: description)
        }
    }
}
