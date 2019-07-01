//
//  APIManager.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import Foundation
typealias APICompletionBlock = (_ success: Bool, _ json: [String: Any]?, _ error: Error?) -> Void
class APIManager: NSObject {
    
    //MARK:-
    //MARK:- Profile
    class func getProfile(completion: @escaping APICompletionBlock) {
        BaseAPIManager.shared.request(APIEndPoints.FITBIT.getProfile.rawValue, params: [:], method: "GET") { (success, json, error) in
            if success {
                completion(success, json, nil)
            } else {
                completion(success, nil, error)
            }
        }
    }
    
    //MARK:-
    //MARK:- Activity
    class func fetchActivities(for date: Date, completion: @escaping APICompletionBlock) {
        let startDate = date.dateString()
        let datePath = "\(startDate).json"
        let url = APIEndPoints.FITBIT.fetchActivities.rawValue + datePath
        BaseAPIManager.shared.request(url, method: "GET") { (success, json, error) in
            completion(success, json, error)
        }
    }
    
    //MARK:-
    //MARK:- Steps
    class func fetchSteps(for dateRange: DateInterval, completion: @escaping APICompletionBlock) {
        let startDate = dateRange.start.dateString()
        let endDate = dateRange.end.dateString()
        let datePath = "\(startDate)/\(endDate).json"
        return fetchSteps(for: datePath, completion: completion)
    }
    
    private class func fetchSteps(for datePath: String, completion: @escaping APICompletionBlock) {
        let url = APIEndPoints.FITBIT.fetchStep.rawValue + datePath
        BaseAPIManager.shared.request(url, method: "GET") { (success, json, error) in
            completion(success, json, error)
        }
    }
    
    //MARK:-
    //MARK:-Calories
    class func fetchCalories(for dateRange: DateInterval, completion: @escaping APICompletionBlock) {
        let startDate = dateRange.start.dateString()
        let endDate = dateRange.end.dateString()
        let datePath = "\(startDate)/\(endDate).json"
        return fetchCalories(for: datePath, completion: completion)
    }
    
    private class func fetchCalories(for datePath: String, completion: @escaping APICompletionBlock) {
        let url = APIEndPoints.FITBIT.fetchCalories.rawValue + datePath
        BaseAPIManager.shared.request(url, method: "GET") { (success, json, error) in
            completion(success, json, error)
        }
    }
}
