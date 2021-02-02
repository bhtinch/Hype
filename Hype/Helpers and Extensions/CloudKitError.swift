//
//  CloudKitError.swift
//  Hype
//
//  Created by Benjamin Tincher on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import Foundation

enum CloudKitError: LocalizedError {
    case ckError(Error)
    case recordError
}
