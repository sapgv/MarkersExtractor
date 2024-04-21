//
//  TXTProfile.swift
//
//
//  Created by Grigory Sapogov on 21.04.2024.
//

import Foundation
import Logging

public class TXTProfile: NSObject, ProgressReporting, ExportProfile {
    // ExportProfile
    public typealias Payload = TXTExportPayload
    public typealias Icon = EmptyExportIcon
    public typealias PreparedMarker = StandardExportMarker
    public static let profile: ExportProfileFormat = .txt
    public static let isMediaCapable: Bool = false
    public var logger: Logger?
    
    // ProgressReporting
    public let progress: Progress
    
    public required init(logger: Logger? = nil) {
        self.logger = logger
        progress = Self.defaultProgress
    }
    
}
