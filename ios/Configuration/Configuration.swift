//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import UIKit

class Configuration: Codable {
  // One and only instance of Configuration
  static let shared: Configuration = Configuration()

  private let kRemoteConfigurationStore =
    "https://profiles.mvoipctsi.com:8900/configuration"

  static let kTransportNames = ["TCP", "TLS", "UDP"]

  static let kTransportTCP = 0
  static let kTransportTLS = 1
  static let kTransportUDP = 2

  var sipServerHost: String
  var sipLocalPort: UInt16
  var sipServerPort: UInt16
  var sipUsername: String
  var sipPassword: String
  var sipRealm: String
  var sipTransport: Int
  var turnHost: String
  var turnUsername: String
  var turnPassword: String
  var turnRealm: String
  var stunHost: String
  var iceEnabled: Bool
  var srtpEnabled: Bool
  var answerTimeout: Double

  private init() {
    let config = UserDefaults.standard
    if !config.bool(forKey: "settingsSavedByUser") {
      sipServerHost = "testsipcc.mvoipctsi.com"
      sipLocalPort = 8993
      sipServerPort = 8993
      sipUsername = ""
      sipPassword = ""
      sipRealm = "*"
      sipTransport = 0
      turnHost = ""
      turnUsername = ""
      turnPassword = ""
      turnRealm = ""
      stunHost = ""
      iceEnabled = false
      srtpEnabled = false
      answerTimeout = 60
    } else {
      sipServerHost = config.string(forKey: "sipServerHost")!
      sipLocalPort = UInt16(config.integer(forKey: "sipLocalPort"))
      sipServerPort = UInt16(config.integer(forKey: "sipServerPort"))
      sipUsername = config.string(forKey: "sipUsername")!
      sipPassword = config.string(forKey: "sipPassword")!
      sipRealm = config.string(forKey: "sipRealm")!
      sipTransport = config.integer(forKey: "sipTransport")
      turnHost = config.string(forKey: "turnHost")!
      turnUsername = config.string(forKey: "turnUsername")!
      turnPassword = config.string(forKey: "turnPassword")!
      turnRealm = config.string(forKey: "turnRealm")!
      stunHost = config.string(forKey: "stunHost")!
      iceEnabled = config.bool(forKey: "iceEnabled")
      srtpEnabled = config.bool(forKey: "srtpEnabled")
      answerTimeout = config.double(forKey: "answerTimeout")
    }
  }

  private func saveChanges() {
    let config = UserDefaults.standard
    config.set(true, forKey: "settingsSavedByUser")
    config.set(sipServerHost, forKey: "sipServerHost")
    config.set(sipLocalPort, forKey: "sipLocalPort")
    config.set(sipServerPort, forKey: "sipServerPort")
    config.set(sipUsername, forKey: "sipUsername")
    config.set(sipPassword, forKey: "sipPassword")
    config.set(sipRealm, forKey: "sipRealm")
    config.set(sipTransport, forKey: "sipTransport")
    config.set(turnHost, forKey: "turnHost")
    config.set(turnUsername, forKey: "turnUsername")
    config.set(turnPassword, forKey: "turnPassword")
    config.set(turnRealm, forKey: "turnRealm")
    config.set(stunHost, forKey: "stunHost")
    config.set(iceEnabled, forKey: "iceEnabled")
    config.set(srtpEnabled, forKey: "srtpEnabled")
    config.set(answerTimeout, forKey: "answerTimeout")
  }

  func refreshFromRemote() throws {
    //        let identifier = UIDevice.current.identifierForVendor!
    //        let storeUrl = URL(string: "\(kRemoteConfigurationStore)/\(identifier)")!
    //        let task = URLSession.shared.dataTask(with: storeUrl) { (data, response, error) in
    //            if error != nil {
    //
    //            }
    //        }
  }

  func doPostUpdateActions() throws {
    saveChanges()
    CallManager.shared.restart()
  }
}
