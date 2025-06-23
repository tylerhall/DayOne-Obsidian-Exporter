//
//  main.swift
//  d1obsidian
//
//  Created by Tyler Hall on 6/23/25.
//

import Foundation
import Yams

struct Journal: Codable {
    var entries: [Entry]
}

struct Entry: Codable {
    var uuid: String
    var text: String?
    var creationDate: Date
    var timeZone: String
    var latitude: Double?
    var longtiude: Double?
    var placeName: String?
    var localityName: String?
    var administrativeArea: String?
    var weather: Weather?
    var photos: [Photo]?
    var videos: [Video]?
}

struct Weather: Codable {
    var conditionsDescription: String
    var weatherCode: String
    var temperatureCelsius: Double
}

struct Photo: Codable {
    var orderInEntry: Int
    var identifier: String
    var type: String
    var md5: String
}

struct Video: Codable {
    var orderInEntry: Int
    var identifier: String
    var type: String
    var md5: String
}

let journalPath = CommandLine.arguments[0]
let outputPath = CommandLine.arguments[1]

let journalURL = URL(fileURLWithPath: journalPath)
let outputDirURL = URL(fileURLWithPath: outputPath)

let rootDirURL = journalURL.deletingLastPathComponent()

let data = try! Data(contentsOf: journalURL)

var allEntries: [String: [Entry]] = [:]

do {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let journal = try decoder.decode(Journal.self, from: data)
    for var entry in journal.entries {
        if let text = entry.text {
            entry.text = text.replacingOccurrences(of: "\\", with: "")
        }
        let key = entry.creationDate.key
        if allEntries[key] == nil {
            allEntries[key] = []
        }
        allEntries[key]?.append(entry)
    }
} catch {
    print(error)
}

let nfEntryCount = NumberFormatter()
nfEntryCount.minimumIntegerDigits = 3
nfEntryCount.maximumFractionDigits = 0

for (key, entries) in allEntries {
    guard let firstEntryDate = entries.first?.creationDate as Date? else { continue }
    let entryDirURL = outputDirURL
        .appendingPathComponent(firstEntryDate.year)
        .appendingPathComponent(firstEntryDate.monthDirName)
        .appending(component: firstEntryDate.key)
    try? FileManager.default.createDirectory(at: entryDirURL, withIntermediateDirectories: true)

    let sortedEntries = entries.sorted { $0.creationDate < $1.creationDate }

    for i in 0..<sortedEntries.count {
        let countStr = nfEntryCount.string(from: NSNumber(integerLiteral: i))!
        let entryURL = entryDirURL.appendingPathComponent(key + " - \(countStr).md")
        
        var entry = sortedEntries[i]

        var text = entry.text ?? ""

        let sortedPhotos = entry.photos?.sorted { $0.orderInEntry < $1.orderInEntry } ?? []
        for photo in sortedPhotos {
            let needle = "![](dayone-moment://\(photo.identifier)"
            let replacement = "![](\(photo.identifier).\(photo.type)"
            text = text.replacingOccurrences(of: needle, with: replacement)

            let photoURL = rootDirURL.appending(component: "photos").appending(component: photo.md5).appendingPathExtension(photo.type)
            let photoDestURL = entryDirURL.appending(component: photo.identifier).appendingPathExtension(photo.type)

            do {
                try FileManager.default.copyItem(at: photoURL, to: photoDestURL)
            } catch {
                print(error.localizedDescription)
            }
        }

        let sortedVideos = entry.videos?.sorted { $0.orderInEntry < $1.orderInEntry } ?? []
        for video in sortedVideos {
            let needle = "![](dayone-moment:/video/\(video.identifier)"
            let replacement = "![](\(video.identifier).\(video.type)"
            text = text.replacingOccurrences(of: needle, with: replacement)

            let videoURL = rootDirURL.appending(component: "videos").appending(component: video.md5).appendingPathExtension(video.type)
            let videoDestURL = entryDirURL.appending(component: video.identifier).appendingPathExtension(video.type)
            
            do {
                try FileManager.default.copyItem(at: videoURL, to: videoDestURL)
            } catch {
                print(error.localizedDescription)
            }
        }

        text = text.replace(regexPattern: "dayone-moment:\\/workout\\/[a-zA-Z0-9-]+", replacement: "")
        text = text.replace(regexPattern: "dayone-moment:\\/location\\/[a-zA-Z0-9-]+", replacement: "")

        entry.text = nil
        entry.photos = nil
        entry.videos = nil

        let encoder = YAMLEncoder()
        let encodedYAML = try encoder.encode(entry)
        let out = "---\n" + encodedYAML + "\n---\n" + text + "\n"

        do {
            try out.write(to: entryURL, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}
