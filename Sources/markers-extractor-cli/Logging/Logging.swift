//
//  Logging.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation
import Logging

fileprivate var consoleLogHandler: LogHandler?
fileprivate var fileLogHandler: LogHandler?

extension MarkersExtractorCLI {
    func fileAndConsoleLogFactory(label: String, logLevel: Logger.Level?, logFile: URL?) -> LogHandler {
        guard let logLevel else {
            return SwiftLogNoOpLogHandler()
        }
        
        var logHandlers: [LogHandler] = [
            consoleLogFactory(label: label, logLevel: logLevel)
        ]
        
        if let logFile, 
           let fileLogger = fileLogFactory(label: label, logLevel: logLevel, logFile: logFile)
        {
            logHandlers.insert(fileLogger, at: 0)
        }
        
        return MultiplexLogHandler(logHandlers)
    }
    
    func consoleLogFactory(label: String, logLevel: Logger.Level) -> LogHandler {
        if let consoleLogHandler { return consoleLogHandler }
        
        var handler = ConsoleLogHandler(label: label)
        handler.logLevel = logLevel
        
        consoleLogHandler = handler
        
        return handler
    }
    
    func fileLogFactory(label: String, logLevel: Logger.Level, logFile: URL?) -> LogHandler? {
        guard let logFile else { return nil }
        
        if let fileLogHandler { return fileLogHandler }
        
        do {
            var handler = try FileLogHandler(label: label, localFile: logFile)
            handler.logLevel = logLevel
            
            fileLogHandler = handler
            
            return handler
        } catch {
            print(
                "Cannot write to log file \(logFile.lastPathComponent.quoted):"
                + " \(error.localizedDescription)"
            )
            return nil
        }
    }
}
