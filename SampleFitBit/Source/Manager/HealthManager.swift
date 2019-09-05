//
//  File.swift
//  StepStats
//
//  Created by Mayank Kumar on 4/15/16.
//  Copyright © 2016 Mayank Kumar. All rights reserved.
//

import HealthKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class HealthManager {

    
    let kit = HKHealthStore()
    var query: HKObserverQuery?
    
    func checkAuth() -> Bool {
        var success = true
        if HKHealthStore.isHealthDataAvailable() {
            let stepCounter = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            kit.requestAuthorization(toShare: nil, read: stepCounter as? Set<HKObjectType>) { bool, error in
                success = bool
            }
        }
        else {
            return false
        }
        return success
    }

    func listenForUpdates(startDate : Date ,_ completionHandler: @escaping (Double, Bool) -> Void) {
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let updateHandler: (HKObserverQuery?, HKObserverQueryCompletionHandler?, Error?) -> Void = { query, completion, error in
            if error == nil {
                self.fetchStepCount(startDate, Date(), completionHandler)
            } else {
                
            }
        }
        
        self.query = HKObserverQuery(sampleType: type!, predicate: nil, updateHandler: updateHandler)
        kit.execute(query!)
    }
    
    func stopLiveUpdates() {
        kit.stop(query!)
    }
    
    func fetchStepCount(_ startDate : Date  ,_ endDate : Date,_ completionHandler: @escaping (Double, Bool) -> Void) {

        let endDate = Date()
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions())
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 10, sortDescriptors: nil) { _, results, error in
            var steps: Double = 0
            if results?.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    steps += result.quantity.doubleValue(for: HKUnit.count())
                }
                completionHandler(steps, true)
            }
            else {
                print("failure")
                completionHandler(steps, false)
            }
        }
        kit.execute(query)
    }

}
