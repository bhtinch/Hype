//
//  UserError.swift
//  Hype
//
//  Created by Marcus Armstrong on 2/6/20.
//  Copyright © 2020 RYAN GREENBURG. All rights reserved.
//

import Foundation

enum UserError: Error {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return ""
        case .unexpectedRecordsFound:
            return ""
        case .noUserLoggedIn:
            return ""
        }
    }
}
