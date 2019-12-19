//
//  UserController.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/26/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
// MARK: - Day 3 Changes
// MARK: - Day 4 Changes
// Edit createUser to accomodate images
class UserController {
    
    static let shared = UserController()
    
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    enum UserError: Error {
        case ckError(Error)
        case couldNotUnwrap
        case unexpectedRecordsFound
        case noUserLoggedIn
    }
    
    func createUserWith(_ username: String, profilePhoto: UIImage?, completion: @escaping (_ result: Result<User?, UserError>) -> Void) {
        // Fetch the AppleID User reference and handle User creation in the closure
        fetchAppleUserReference { (reference) in
            // Unwrap the reference
            guard let reference = reference else { completion(.failure(.noUserLoggedIn)) ; return }
            // Initialize a new User object, passing in the username parameter and the unwrapped reference
            let newUser = User(username: username, appleUserReference: reference, profilePhoto: profilePhoto)
            // Create a CKRecord from the user just created
            let record = CKRecord(user: newUser)
            // Call the save method on the database, pass in the record
            self.publicDB.save(record) { (record, error) in
                // Handle the optional error
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.ckError(error)))
                }
                // Unwrap the saved record, unwrap the user initialized from that record
                guard let record = record,
                    let savedUser = User(ckRecord: record)
                    else { completion(.failure(.couldNotUnwrap)) ; return }
                // Set the currentUser as the savedUser and complete true
                self.currentUser = savedUser
                print("Created User: \(record.recordID.recordName) successfully")
                completion(.success(savedUser))
            }
        }
    }
    
    func fetchUser(completion: @escaping (_ result: Result<User?, UserError>) -> Void) {
        // Step 4 - Fetch and unwrap the appleUserRef to pass in for the predicate
        fetchAppleUserReference { (reference) in
            guard let reference = reference else { completion(.failure(.noUserLoggedIn)) ; return }
            // Step 3 - Init the predicate needed by the query
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference])
            // Step 2 - Init the query to pass into the .perform method
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            // Step 1 - Implement the .perform method
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                // Handle the optional error
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(.failure(.ckError(error)))
                }
                // Unwrap the record and foundUser initialized from the record
                guard let record = records?.first,
                    let foundUser = User(ckRecord: record)
                    else { completion(.failure(.couldNotUnwrap)) ; return }
                // Set the current user to the foundUser and complete true
                self.currentUser = foundUser
                print("Fetched User: \(record.recordID.recordName) successfully")
                completion(.success(foundUser))
            }
        }
    }
    
    func fetchUserFor(_ hype: Hype, completion: @escaping (User?) -> Void) {
        guard let userID = hype.userReference?.recordID else { completion(nil) ; return }
        
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID])
        let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
            
            guard let record = records?.first,
                let foundUser = User(ckRecord: record)
                else { completion(nil) ; return }
            print("Found user for hype")
            completion(foundUser)
        }
    }
    
    private func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(reference)
            }
        }
    }
    
    func update(_ user: User, completion: @escaping (_ success: Bool) -> Void) {
        
    }
    
    func delete(_ user: User, completion: @escaping (_ success: Bool) -> Void) {
        
    }
}
