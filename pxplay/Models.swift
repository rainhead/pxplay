//
//  Query.swift
//  pxplay
//
//  Created by Peter Abrahamsen on 11/3/19.
//  Copyright © 2019 Peter Abrahamsen. All rights reserved.
//

import Foundation
import OrderedDictionary

typealias EntityId = UUID

class AppData: Codable, Equatable, ObservableObject {
    var revision = 0
    var people: OrderedDictionary<EntityId, Person>
    var spaces: OrderedDictionary<EntityId, Space>
    
    static func ==(left: AppData, right: AppData) -> Bool {
        left.revision == right.revision
    }
}

struct Person: Hashable, Codable, Identifiable {
    var entityId: UUID
    var name: String
    
    var id: UUID { entityId }
}

struct Space: Codable, Identifiable {
    var entityId: UUID
    var participants: [EntityId]
    var unreadCount: Int
    var messages: [Message]
    
    var id: UUID { get { entityId } }
}

struct Message: Hashable, Codable, Identifiable {
    var entityId: UUID
    var author: EntityId
    var body: String
    var sentAt: Date
    
    var id: UUID { entityId }
}

func loadJSON<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
