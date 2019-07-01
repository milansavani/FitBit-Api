//
//  AuthenticationController.swift
//  SampleFitBit
//
//  Created by mobiiworld on 27/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import SafariServices
import Foundation

protocol AuthenticationProtocol {
    func authorizationDidFinish(_ success :Bool)
}

class AuthenticationController: NSObject {
    let clientID = Config.shared.fitbitClientID
    let clientSecret = Config.shared.fitbitClientSecret
    let authURL = Config.shared.authURL
    static let redirectURI = Config.shared.appURI
    let defaultScope = "sleep+settings+nutrition+activity+social+heartrate+profile+weight+location"
    
    var authorizationVC: SFSafariViewController?
    var delegate: AuthenticationProtocol?
    var authenticationToken: String?
    
    init(delegate: AuthenticationProtocol?) {
        self.delegate = delegate
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationConstants.FitBit.launchNotification.rawValue), object: nil, queue: nil, using: { [weak self] (notification: Notification) in
            let success: Bool
            if let token = AuthenticationController.extractToken(notification, key: "#access_token") {
                self?.authenticationToken = token
                NSLog("You have successfully authorized")
                success = true
            } else {
                print("There was an error extracting the access token from the authentication response.")
                success = false
            }
            
            self?.authorizationVC?.dismiss(animated: true, completion: {
                self?.delegate?.authorizationDidFinish(success)
            })
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public API
    
    public func login(fromParentViewController viewController: UIViewController) {
        guard let url = URL(string: authURL+"?response_type=token&client_id="+clientID+"&redirect_uri="+AuthenticationController.redirectURI+"&scope="+defaultScope+"&expires_in=604800") else {
            NSLog("Unable to create authentication URL")
            return
        }
        
        let authorizationViewController = SFSafariViewController(url: url)
        authorizationViewController.delegate = self
        authorizationVC = authorizationViewController
        viewController.present(authorizationViewController, animated: true, completion: nil)
    }
    
    public static func logout(completion: @escaping (Bool, [String: Any], Error?)->()) {
        // TODO
        let base64 = String(format: "%@:%@", Config.shared.fitbitClientID, Config.shared.fitbitClientSecret).data(using: .utf8)?.base64EncodedString()
        let queryParams: [String: Any] = ["token": AuthenticationController.getToken(), "client_id": Config.shared.fitbitClientID]
        var absoluteUrl = "https://api.fitbit.com/oauth2/revoke"
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
        request.httpMethod = "POST"
        let headers = ["Authorization": String(format: "Basic %@", base64 ?? ""), "Content-Type": "application/x-www-form-urlencodedn"]
        headers.forEach { (arg) in
            let (key, value) = arg
            request.addValue(value, forHTTPHeaderField: key)
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("false")
                completion(false, [:], error)
            } else {
                switch (response as! HTTPURLResponse).statusCode {
                    
                case 200:
                    self.clearToken()
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
    
    private static func extractToken(_ notification: Notification, key: String) -> String? {
        guard let url = notification.userInfo?[UIApplication.LaunchOptionsKey.url] as? URL else {
            NSLog("notification did not contain launch options key with URL")
            return nil
        }
        let strippedURL = url.absoluteString.replacingOccurrences(of: AuthenticationController.redirectURI, with: "")
        guard let token = self.parametersFromQueryString(strippedURL)[key] else { return nil }
        return token
    }
    
    // TODO: this method is horrible and could be an extension and use some functional programming
    private static func parametersFromQueryString(_ queryString: String?) -> [String: String] {
        var parameters = [String: String]()
        if (queryString != nil) {
            let parameterScanner: Scanner = Scanner(string: queryString!)
            var name:NSString? = nil
            var value:NSString? = nil
            while (parameterScanner.isAtEnd != true) {
                name = nil;
                parameterScanner.scanUpTo("=", into: &name)
                parameterScanner.scanString("=", into:nil)
                value = nil
                parameterScanner.scanUpTo("&", into:&value)
                parameterScanner.scanString("&", into:nil)
                if (name != nil && value != nil) {
                    parameters[name!.removingPercentEncoding!]
                        = value!.removingPercentEncoding!
                }
            }
        }
        return parameters
    }
    
    public static func getToken() -> String {
        return UserDefaults.standard.string(forKey: userDefaultKey.accessToken.rawValue) ?? ""
    }
    
    public static func setToken(token: String) {
        UserDefaults.standard.set(String(format: "%@", token), forKey: userDefaultKey.accessToken.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public static func clearToken() {
        UserDefaults.standard.removeObject(forKey: userDefaultKey.accessToken.rawValue)
        UserDefaults.standard.synchronize()
    }
}

// MARK: SFSafariViewControllerDelegate
extension AuthenticationController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.authorizationDidFinish(false)
    }
}
