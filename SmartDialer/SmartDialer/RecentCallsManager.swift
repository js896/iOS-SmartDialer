//
//  RecentCallsManager.swift
//  SmartDialer
//
//  Created by Mihai Costiug on 20/02/2017.
//  Copyright © 2017 Mihai Costiug. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// This class should persistently keep track of all the calls initiated from within the app and provide a total number of calls for each individual phone number.
class RecentCallsManager: NSObject {
    static let sharedInstance = RecentCallsManager()
    
    private var callCounters: [CallCounter] = []
    
    private override init() {
        super.init()
        
        self.fetchAllCallCounters()
        self.addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Public
    
    public func incrementCounterFor(phoneNumber: String, withDate date: Date) {
        DispatchQueue.global(qos: .background).async {
            var alreadyExists = false
            
            for callCounter in self.callCounters {
                if callCounter.phoneNumber == phoneNumber {
                    callCounter.callCount += 1
                    callCounter.lastCallDate = date
                    
                    alreadyExists = true
                    break
                }
            }
            
            if !alreadyExists {
                let context = self.persistentContainer.viewContext
                let callCounter = CallCounter(context: context)
                callCounter.phoneNumber = phoneNumber
                callCounter.callCount = 1
                callCounter.lastCallDate = date
                context.insert(callCounter)
            }
            
            self.saveContext()
        }
    }
    
    public func callCountAndLastDateFor(phoneNumber: String) -> (callCount: Int, lastCallDate: Date?) {
        let fetchRequest = NSFetchRequest<CallCounter>(entityName: "CallCounter")
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        
        var result: (callCount: Int, lastCallDate: Date?) = (0, nil)
        
        do {
            if let callCounter = try self.persistentContainer.viewContext.fetch(fetchRequest).first {
                result.callCount = Int(callCounter.callCount)
                result.lastCallDate = callCounter.lastCallDate as Date?
            }
        } catch {
            
        }
        
        return result
    }
    
    //MARK:- Private
    
    private func fetchAllCallCounters() {
        DispatchQueue.global(qos: .background).async {
            do {
                let context = self.persistentContainer.viewContext
                self.callCounters = try context.fetch(CallCounter.fetchRequest())
            } catch {
                print("Fetching call counters failed")
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminateNotification(notification:)), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackgroundNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    //MARK:- Notifications
    
    @objc func applicationWillTerminateNotification(notification: NSNotification) {
        self.saveContext()
    }
    
    @objc func applicationDidEnterBackgroundNotification(notification: NSNotification) {
        self.saveContext()
    }
    
    //MARK:- Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CallCounterModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
            }
        })
        return container
    }()
    
    //MARK:- Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
            }
        }
    }
}
