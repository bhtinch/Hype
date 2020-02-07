//
//  HypeError.swift
//  Hype
//
//  Created by Marcus Armstrong on 2/6/20.
//  Copyright © 2020 RYAN GREENBURG. All rights reserved.
//

import Foundation

enum HypeError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get this Hype, That's not very Hype..."
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete."
        case .noUserLoggedIn:
            return "A user was not found for the current session."
        }
    }
}
