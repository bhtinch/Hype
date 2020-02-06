//
//  UserController.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit
// MARK: - Day 3 Changes

class UserController {
    
    static let shared = UserController()
    
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    /**
     Creates a User and saves it to CloudKit
     
     - Parameters:
        - username: String value to pass into the User initializer
        - completion: Escaping completion block for the method
        - result: Result found in the completion block with success returning an optional User and failure returning a UserError
     */
    func createUserWith(_ username: String, completion: @escaping (Result<User?, UserError>) -> Void) {
        // Fetch the AppleID User reference and handle User creation in the closure
        fetchAppleUserReference { (result) in
            
            switch result {
            case .success(let reference):
                // Unwrap the reference
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn)) }
                // Initialize a new User object, passing in the username parameter and the unwrapped reference
                let newUser = User(username: username, appleUserReference: reference)
                // Create a CKRecord from the user just created
                let record = CKRecord(user: newUser)
                // Call the save method on the database, pass in the record
                self.publicDB.save(record) { (record, error) in
                    // Handle the optional error
                    if let error = error {
                        completion(.failure(.ckError(error)))
                    }
                    // Unwrap the saved record, unwrap the user initialized from that record
                    guard let record = record,
                        let savedUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap)) }
                    
                    print("Created User: \(record.recordID.recordName) successfully")
                    completion(.success(savedUser))
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    /**
     Fetches the User object that points to the currenly logged in AppleID User from the publicDatabase
     
     - Parameters:
        - completion: Escaping completion block for the method
        - result: Result found in the completion block with success returning an optional User and failure returning a UserError
     */
    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        // Step 4 - Fetch and unwrap the appleUserRef to pass in for the predicate
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn)) }
                // Step 3 - Init the predicate needed by the query
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference])
                // Step 2 - Init the query to pass into the .perform method
                let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
                // Step 1 - Implement the .perform method
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    // Handle the optional error
                    if let error = error {
                        completion(.failure(.ckError(error)))
                    }
                    // Unwrap the record and foundUser initialized from the record
                    guard let record = records?.first,
                        let foundUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap)) }
                    
                    print("Fetched User: \(record.recordID.recordName) successfully")
                    completion(.success(foundUser))
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    /**
     Fetches the recordID of the currently logged in AppleID User
     
     - Parameters:
        - completion: Escaping completion block for the method
        - reference: Optional reference for the found AppleID User
     */
    private func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {

        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference))
            }
        }
    }
    
    func update(_ user: User, completion: @escaping (Result<Bool, UserError>) -> Void) {
        
    }
    
    func delete(_ user: User, completion: @escaping (Result<Bool, UserError>) -> Void) {
        
    }
}
