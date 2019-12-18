//
//  HypeController.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/25/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    /// The publicCloudDatabase of the default container
    let publicDB = CKContainer.default().publicCloudDatabase
    /// Shared instance of HypeController class
    static let shared = HypeController()
    /// Source of Truth array of Hype objects
    var hypes: [Hype] = []
    
    enum HypeError: Error {
        case ckError(Error)
        case couldNotUnwrap
        case unexpectedRecordsFound
    }
    
     /**
        Saves a Hype object to CloudKit
        
        - Parameters:
           - text: String value for the Hype objects body
           - completion: Escaping completion block for the method
           - result: Result found in the completion block with success returning an optional Hype and failure returning a HypeError
        */
       func saveHype(with text: String, completion: @escaping (_ result: Result<Hype?, HypeError>) -> Void) {
        // Inititialize a Hype object with the text value passed in as a parameter
        let newHype = Hype(body: text)
        // Initialize a CKRecord from the Hype object to be saved in CloudKit
        let hypeRecord = CKRecord(hype: newHype)
        // Call the CKContainer's save method on the database
        publicDB.save(hypeRecord) { (record, error) in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            // Unwrap the CKRecord that was saved
            guard let record = record,
                // Re-create the same Hype object from that record that we know was saved
                let savedHype = Hype(ckRecord: record)
                else { completion(.failure(.couldNotUnwrap)) ; return }
            print("Saved Hype successfully")
            // Insert the successfully saved Hype object at the first index of our Source of Truth array
            self.hypes.insert(savedHype, at: 0)
            // Complete with success
            completion(.success(savedHype))
        }
    }
    
    /**
     Fetches all Hypes stored in the CKContainer's publicDataBase
     
     - Parameters:
        - completion: Escaping completion block for the method
        - result: Result found in the completion block with success returning an array of Hype objects and failure returning a HypeError
     */
    func fetchAllHypes(completion: @escaping (_ result: Result<[Hype]?, HypeError>) -> Void) {
        // Step 3 - Create the Predicate needed for the query parameters
        let predicate = NSPredicate(value: true)
        // Step 2 - Create the query needed for the perform(query) method
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        // Step 1 - Access the perform(query) method on the database
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            // Unwrap the found CKRecord objects
            guard let records = records else { completion(.failure(.couldNotUnwrap)) ; return }
            print("Fetched Hypes successfully")
            // Map through the found records, appling the Hype(ckRecord:) convenience init method as the transform
            let hypes = records.compactMap({ Hype(ckRecord: $0) })
            // Set the Source of Truth array
            self.hypes = hypes
            // Complete with success
            completion(.success(hypes))
        }
    }
    
    // MARK: - Day 2 Changes
    // Need to add in CKRecord.ID onto the model for the modification operations
    
    /**
    Updates a Hype with changed keys.
     
     - Parameters:
        - hype: The Hype object that will be passed into the update operation
        - completion: Escaping completion block for the method
        - result: Result found in the completion block with success returning an optional Hype object that was updated and failure returning a HypeError
     */
    func update(_ hype: Hype, completion: @escaping (_ result: Result<Hype?, HypeError>) -> Void) {
        // Step 2.a Create the record to save (update)
        let record = CKRecord(hype: hype)
        // Step 2 - Create the operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // Step 3 - Adjust the properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            // Unwrap the record that was updated and complete true
            guard let record = records?.first,
                let updatedHype = Hype(ckRecord: record)
                else { completion(.failure(.couldNotUnwrap)) ; return }
            print("Updated \(record.recordID) successfully in CloudKit")
            completion(.success(updatedHype))
        }
        // Step 1 - Add the operation to the database
        publicDB.add(operation)
    }
    
    /**
    Deletes a Hype with from the database
     
     - Parameters:
        - hype: The Hype object that will be passed into the delete operation
        - completion: Escaping completion block for the method
        - result: Result found in the completion block with success returning a boolean and failure returning a HypeError
     */
    func delete(_ hype: Hype, completion: @escaping (_ result: Result<Bool, HypeError>) -> Void) {
        // Step 2 - Declare the operation
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        // Step 3 - Set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {records, _, error in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            // Check to make sure there are no returned records and complete true
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(.success(true))
            } else {
                print("Unexpected records were returned when trying to delete")
                completion(.failure(.unexpectedRecordsFound))
            }
        }
        // Step 1 - Add the operation to the database
        publicDB.add(operation)
    }
    
    /**
     Subscribes the device to receive remote notifications from changes made to the database
     
     - Parameters:
        - completion: Escaping completion block for the method
        - error: Optional error returned when saving the CKQuerySubscription to the database
     */
    func subscribeForRemoteNotifications(completion: @escaping (_ error: Error?) -> Void) {
        // Step 2 - Create the needed query to pass into the subscription
        let predicate = NSPredicate(value: true)
        // Step 1 - Create the CKQuerySubscription object
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        // Step 3 - Set the notification properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't Stop the Hype Train!!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        // Step 4 - Save the subscription to the database
        publicDB.save(subscription) { (_, error) in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
}

