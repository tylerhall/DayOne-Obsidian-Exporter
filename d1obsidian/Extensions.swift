//
//  Extensions.swift
//  d1obsidian
//
//  Created by Tyler Hall on 6/23/25.
//

import Foundation

extension Date {
    var year: String {
        let year = Calendar.current.component(.year, from: self)
        let nf = NumberFormatter()
        nf.minimumIntegerDigits = 2
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(integerLiteral: year))!
    }
    
    var month: String {
        let year = Calendar.current.component(.month, from: self)
        let nf = NumberFormatter()
        nf.minimumIntegerDigits = 2
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(integerLiteral: year))!
    }
    
    var day: String {
        let year = Calendar.current.component(.day, from: self)
        let nf = NumberFormatter()
        nf.minimumIntegerDigits = 2
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(integerLiteral: year))!
    }

    var key: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }

    var monthDirName: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM - MMMM"
        return df.string(from: self)
    }
}

extension String {
    func replace(regexPattern: String, replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
            return self
        }
        let range = NSRange(self.startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}
