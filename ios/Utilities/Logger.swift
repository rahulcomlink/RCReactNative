//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import Foundation
import os.log

struct Logger {
  private let componentName: String

  init(componentName: String) {
    self.componentName = componentName
  }

  func write(
    _ format: String, type: OSLogType = .info,
    function: String = #function, line: Int = #line, _ items: CVarArg...
  ) {
    os_log(
      "%s/%s/%d %s", type: type, componentName, function, line,
      String(format: format, arguments: items))
  }
  
  func writeError(_ error: Error, function: String = #function, line: Int = #line) {
    write(error.localizedDescription, type: .error, function: function, line: line)
  }

    
    private static func writeNative(_ level: CLOGLEVEL, _ text: UnsafePointer<Int8>) {
      // Convert the log level to a somewhat appropriate macOS/iOS log type.
      let logType: OSLogType = {
        switch level {
        case CLOG_DEBUG:   return .debug
        case CLOG_INFO:    return .info
        case CLOG_WARNING: return .error
        case CLOG_ERROR:   return .fault
        default:
          // FIXME: Here we're defaulting to info. Perhaps we should assert?
          return .info
        }
      }()
      os_log("ccomsdk> %s", type: logType, String(cString: text))
        Logger.writeLogs(string: String(cString: text))
    }
    
    static func attachSDKLogger() {
      CLogSetLevel(CLOG_DEBUG)
      CLogSetWriter({ level, text in Logger.writeNative(level, text!) })
    }
    
    static func writeLogs(string : String){
    
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sipLogs.txt")
        if let handle = try? FileHandle(forWritingTo: log) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
    
    static func clearAllLogs(){
        let fm = FileManager.default
        let log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sipLogs.txt")
        let text = ""
        try? text.write(to: log, atomically: true, encoding: .utf8)
    }
}
