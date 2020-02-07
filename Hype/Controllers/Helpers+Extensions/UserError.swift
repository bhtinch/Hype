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
    case noUserForHype
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to find a user"
        case .unexpectedRecordsFound:
            return "Unexpected records were returned when trying to delete."
        case .noUserLoggedIn:
            return "There is currently no user logged in."
        case .noUserForHype:
            return "No user was found to be associated with this hype."
        }
    }
}
