//
//  ApiManager.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import Foundation

enum APIEndPoints {
    enum FITBIT: String {
        case getAccessToken = "/oauth2/token"
        case getProfile = "profile.json"
        
        //ACTIVITY
        case fetchActivities = "activities/date/"
        case fetchStep = "activities/steps/date/"
        case fetchCalories = "activities/calories/date/"
        
        //use tracker api for the tracking data "activities/tracker/steps/date/"
    }
    
//    enum ACTIVITY: String {
//       case calories = "activities/calories"
//       case caloriesBMR = "activities/caloriesBMR"
//       case steps = "activities/steps"
//       case distance = "activities/distance"
//       case floors = "activities/floors"
//       case elevation = "activities/elevation"
//       case minutesSedentary = "activities/minutesSedentary"
//       case minutesLightlyActive = "activities/minutesLightlyActive"
//       case minutesFairlyActive = "activities/minutesFairlyActive"
//       case minutesVeryActive = "activities/minutesVeryActive"
//       case activityCalories = "activities/activityCalories"
//
//    }
}

class BaseAPIManager {
    static var shared = BaseAPIManager()
        
    func request(_ url: String,queryParams: [String: Any] = [:], params : [String : Any] = [:] , method : String , completion: @escaping (Bool, [String: Any], Error?)->()) {
        
        var absoluteUrl = Config.shared.domain + url
        if !(queryParams.isEmpty) {
            absoluteUrl.append("?")
            var array:[String] = []
            queryParams.forEach { (arg) in
                let (key, value) = arg
                let str = key + "=" + (value as! String)
                array.append(str)
            }
            absoluteUrl.append(array.joined(separator: "&"))
        }
        print("URL ===> \(absoluteUrl)")
        guard let serviceUrl = URL(string: absoluteUrl) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = method
        let headers = ["Authorization": "Bearer \(AuthenticationController.getToken())", "Content-Type": "application/json", "Accept-Locale": "en_US", "Accept-Language": "en_US"]
        headers.forEach { (arg) in
            let (key, value) = arg
            request.addValue(value, forHTTPHeaderField: key)
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(false, [:], error)
            } else {
                switch (response as! HTTPURLResponse).statusCode {
                case 200, 400:
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            completion(true, json as! [String : Any], nil)
                        } catch let error{
                            completion(false, [:], error)
                        }
                    }
                    break
                default:
                    completion(false, [:], error)
                    break
                }
            }
        }.resume()
    }
}
