//
//  HypeController.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/25/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
// MARK: - Day 4 Changes
// Edit saveHype to accomodate adding hypes with images
class HypeController {
    /// The publicCloudDatabase of the default container
    let publicDB = CKContainer.default().publicCloudDatabase
    /// Shared instance of HypeController class
    static let shared = HypeController()
    /// Source of Truth array of Hype objects
    var hypes: [Hype] = []
    
    /**
     Saves a Hype object to CloudKit
     
     - Parameters:
     - text: String value for the Hype objects body
     - completion: Escaping completion block for the method
     - success: Boolean value returned in the completion block indicating a success or failure on saving the CKRecord to CloudKit
     */
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { return completion(.failure(.noUserLoggedIn)) }
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .deleteSelf)
        // Inititialize a Hype object with the text value passed in as a parameter
        let newHype = Hype(body: text, userReference: reference, hypePhoto: photo)
        // Initialize a CKRecord from the Hype object to be saved in CloudKit
        let hypeRecord = CKRecord(hype: newHype)
        // Call the CKContainer's save method on the database
        publicDB.save(hypeRecord) { (record, error) in
            // Handle the optional error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // Unwrap the CKRecord that was saved
            guard let record = record,
                // Re-create the same Hype object from that record that we know was saved
                let savedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            print("Saved Hype: \(record.recordID.recordName) successfully")
            // Complete with success
            completion(.success(savedHype))
        }
    }
    
    /**
     Fetches all Hypes stored in the CKContainer's publicDataBase
     
     - Parameters:
     - completion: Escaping completion block for the method
     - success: Boolean value returned in the completion block indicating a success or failure on fetching the CKRecords from the database
     */
    func fetchAllHypes(completion: @escaping (Result<[Hype]?, HypeError>) -> Void) {
        // Step 3 - Create the Predicate needed for the query parameters
        let predicate = NSPredicate(value: true)
        // Step 2 - Create the query needed for the perform(query) method
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        // Step 1 - Access the perform(query) method on the database
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            // Handle the optional error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // Unwrap the found CKRecord objects
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            print("Fetched Hypes successfully")
            // Map through the found records, appling the Hype(ckRecord:) convenience init method as the transform
            let hypes = records.compactMap({ Hype(ckRecord: $0) })
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
     - success: Boolean value indicating success or falure of the CKModifyRecordsOperation
     */
    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        // Step 2.a Create the record to save (update)
        let record = CKRecord(hype: hype)
        // Step 2 - Create the operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        // Step 3 - Adjust the properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                let hype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            completion(.success(hype))
        }
        // Step 1 - Add the operation to the database
        publicDB.add(operation)
    }
    
    /**
     Deletes a Hype with from the database
     
     - Parameters:
     - hype: The Hype object that will be passed into the delete operation
     - completion: Escaping completion block for the method
     - success: Boolean value indicating success or falure of the CKModifyRecordsOperation
     */
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        // Step 2 - Declare the operation
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        // Step 3 - Set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = {records, _, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(.success(true))
            } else {
                print("Unaccounted records were returned when trying to delete")
                return completion(.failure(.unexpectedRecordsFound))
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
    func subscribeForRemoteNotifications(completion: @escaping (Result<Bool, HypeError>) -> Void) {
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
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            completion(.success(true))
        }
    }
}

