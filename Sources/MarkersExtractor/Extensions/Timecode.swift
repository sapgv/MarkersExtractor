//
//  Timecode.swift
//  
//
//  Created by Grigory Sapogov on 21.04.2024.
//

import TimecodeKit

extension Timecode {
    
    public func stringValueHours(
        format: StringFormat = .default()
    ) -> String {
        let sepDays = " "
        let sepMain = ":"
        let sepFrames = frameRate.isDrop ? ";" : ":"
        let sepSubFrames = "."
        
        var output = ""
        
        output += "\(days != 0 ? "\(days)\(sepDays)" : "")"
        output += "\(hours != 0 ? "\(String(format: "%02ld", hours))\(sepMain)" : "")"
        output += "\(String(format: "%02ld", minutes))\(sepMain)"
        output += "\(String(format: "%02ld", seconds))\(sepFrames)"
        output += "\(String(format: "%0\(frameRate.numberOfDigits)ld", frames))"
        
        if format.showSubFrames {
            let numberOfSubFramesDigits = validRange(of: .subFrames).upperBound.numberOfDigits
            
            output += "\(sepSubFrames)\(String(format: "%0\(numberOfSubFramesDigits)ld", subFrames))"
        }
        
        if format.contains(.filenameCompatible) {
            return output
                .replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: ";", with: "-")
                .replacingOccurrences(of: " ", with: "-")
        } else {
            return output
        }
    }
    
}
