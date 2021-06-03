//
//  IntentHandler.swift
//  IntentHandling
//
//  Created by Arti Mane on 02/06/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import Intents

class IntentHandler: INExtension , INStartCallIntentHandling{
  func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
    let response: INStartCallIntentResponse
        defer {
            completion(response)
        }

        // Ensure there is a person handle
        guard intent.contacts?.first?.personHandle != nil else {
            response = INStartCallIntentResponse(code: .failure, userActivity: nil)
            return
        }

        let userActivity = NSUserActivity(activityType: String(describing: INStartCallIntent.self))

        response = INStartCallIntentResponse(code: .continueInApp, userActivity: userActivity)
       
  }
  
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
