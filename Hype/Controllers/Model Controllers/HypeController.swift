//
//  HypeController.swift
//  Hype
//
//  Created by Benjamin Tincher on 2/1/21.
//  Copyright © 2021 RYAN GREENBURG. All rights reserved.
//

import CloudKit

class HypeController {
    
    static let shared = HypeController()
    
    var hypes: [Hype] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func createHype(with body: String, completion: @escaping (Result<String, CloudKitError>) -> Void) {
        let hype = Hype(body: body)
        let hypeRecord = CKRecord(hype: hype)
        
        publicDB.save(hypeRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print("Description: \(error.localizedDescription)")
                    print("======== ERROR ========")
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record,
                      let savedHype = Hype(ckRecord: record) else { return completion(.failure(.recordError)) }
                
                self.hypes.append(savedHype)
                completion(.success("Successfully saved a Hype!"))
            }
        }
    }
    
    func fetchAllHypes(completion: @escaping (Result<String, CloudKitError>) -> Void) {
        
        let fetchAllPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: fetchAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("======== ERROR ========")
                    print("Function: \(#function)")
                    print("Error: \(error)")
                    print("Description: \(error.localizedDescription)")
                    print("======== ERROR ========")
                    return completion(.failure(.ckError(error)))
                }
                
                guard let records = records else { return completion(.failure(.recordError)) }
                
                let fetchHypes = records.compactMap { Hype(ckRecord: $0) }
                self.hypes = fetchHypes
                completion(.success("Successfully fetched all Hypes!"))
            }
        }
    }
    
}   //  End of Class
