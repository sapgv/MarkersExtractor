//
//  TXTExportPayload.swift
//
//
//  Created by Grigory Sapogov on 21.04.2024.
//

import Foundation

public struct TXTExportPayload: ExportPayload {
    let txtPath: URL
        
    init(projectName: String, outputURL: URL) {
        let txtName = "\(projectName).txt"
        txtPath = outputURL.appendingPathComponent(txtName)
    }
}
