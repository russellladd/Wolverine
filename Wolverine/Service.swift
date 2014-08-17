//
//  Service.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

public class ServiceManager {
    
    public enum Status {
        case NotConnected(NSError?)
        case Connecting
        case Connected(Service)
    }
    
    public var status: Status = .Connecting {
        didSet {
            delegate?.serviceManager(self, didChangeStatus: status)
        }
    }
    
    // TODO: Make this weak
    public var delegate: ServiceManagerDelegate?
    
    private let tokenFetcher: TokenFetcher
    
    public init(credential: Credential) {
        
        tokenFetcher = TokenFetcher(credential: credential)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        
        connect()
    }
    
    deinit {
        
        cancelTokenExpirationTimer()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func reconnect() {
        
        cancelTokenExpirationTimer()
        
        status = .Connecting
        
        connect()
    }
    
    private func connect() {
        
        tokenFetcher.fetchToken() { [weak self] result in
            
            switch result {
                
            case .Success(let token):
                
                self?.status = .Connected(Service(token: token))
                
                self?.scheduleTokenExpirationTimer(token, ifNeeded: true)
                
            case .Error(let error):
                
                self?.status = .NotConnected(error)
            }
        }
    }
    
    private var tokenExpirationTimer: NSTimer?
    
    private func scheduleTokenExpirationTimer(token: Token, ifNeeded: Bool) {
        
        // TODO: Rewrite this with conditionally unwrapped optionals when the compiler is fixed
        if let application = UIApplication.sharedApplication() {
            
            if !ifNeeded || UIApplication.sharedApplication().applicationState == .Active {
                
                tokenExpirationTimer = NSTimer.scheduledTimerWithTimeInterval(token.timeIntervalUntilExpiration, target: self, selector: "tokenExpirationTimerDidFire:", userInfo: nil, repeats: false)
            }
        }
    }
    
    private func cancelTokenExpirationTimer() {
        
        tokenExpirationTimer?.invalidate()
        tokenExpirationTimer = nil
    }
    
    private func tokenExpirationTimerDidFire(timer: NSTimer!) {
        
        reconnect()
    }
    
    private func applicationWillResignActive(notification: NSNotification!) {
        
        cancelTokenExpirationTimer()
    }
    
    private func applicationDidBecomeActive(notication: NSNotification!) {
        
        switch status {
        case .Connected(let service):
            self.scheduleTokenExpirationTimer(service.token, ifNeeded: false)
        default: ()
        }
    }
}

public protocol ServiceManagerDelegate: class {
    
    func serviceManager(serviceManager: ServiceManager, didChangeStatus status: ServiceManager.Status)
}

public class Service {
    
    let token: Token
    
    private var session: NSURLSession
    
    init(token: Token) {
        
        self.token = token;
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        configuration.HTTPAdditionalHeaders = ["Authorization": token.authorization]
        
        session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    final func get(path: String, completionHandler: AnyObjectResult -> ()) -> NSURLSessionDataTask {
        
        let url = "https://api-gw.it.umich.edu".stringByAppendingPathComponent(path)
        
        let task = session.dataTaskWithURL(NSURL(string: url)) { (data, response, taskError) in
            
            var jsonError: NSError?
            
            if taskError != nil {
                
                completionHandler(.Error(taskError))
                
            } else if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) {
                
                completionHandler(.Success(jsonObject))
                
            } else {
                
                completionHandler(.Error(jsonError!))
            }
        }
        
        task.resume()
        
        return task
    }
}
