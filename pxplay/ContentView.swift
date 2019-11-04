//
//  ContentView.swift
//  pxplay
//
//  Created by Peter Abrahamsen on 10/31/19.
//  Copyright © 2019 Peter Abrahamsen. All rights reserved.
//

import UIKit
import SwiftUI

let appData: AppData = loadJSON("queryResults.json")
let viewer = UUID.init(uuidString: "b6134024-fe83-11e9-a439-3b4373fd7cea")!


private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

extension Space {
    func titleForViewer(_ viewer: EntityId, people: [Person]) -> String {
        participants.filter { $0 != viewer }
            .map { participant in people.first { $0.entityId == participant } }
            .map { $0?.name ?? "unknown" }
            .joined(separator: ", ")
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            SpaceList(spaces: appData.spaces, people: appData.people, viewer: viewer)
                .navigationBarTitle(Text("$PX"))
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct SpaceList: View {
    var spaces: [Space]
    var people: [Person]
    var viewer: EntityId

    var body: some View {
        List(spaces) { space in
            NavigationLink(destination: SpaceDetail(space: space, people: self.people, viewer: self.viewer)) {
                SpaceRow(space: space, people: self.people, viewer: self.viewer)
            }
        }
    }
}

struct SpaceList_Previews: PreviewProvider {
    static var previews: some View {
        SpaceList(spaces: appData.spaces, people: appData.people, viewer: viewer)
    }
}

struct Badge: View {
    // show even if count is zero
    var alwaysShow: Bool = false
    var count: Int = 0
    
    var body: some View {
        Text("\(count)")
            .foregroundColor(Color.white)
            .padding(.horizontal, 6.0)
            .background(Color.secondary)
            .cornerRadius(14.0)
    }
}

struct SpaceRow: View {
    var space: Space
    var people: [Person]
    var viewer: EntityId
    
    var body: some View {
        HStack {
            Text(space.titleForViewer(self.viewer, people: people))
            Spacer()
            Badge(count: space.unreadCount)
        }
    }
}

struct SpaceDetail: View {
    var space: Space
    var people: [Person]
    var viewer: EntityId

    lazy var title: String = {
        space.titleForViewer(viewer, people: people)
    }()
    
    var body: some View {
        var prevMessage = space.messages.first
        var runs = [[Message]]()
        var run = [Message]()
        for message in space.messages {
            if message.author == prevMessage?.author {
                run.append(message)
            } else {
                runs.append(run)
                run = [message]
            }
            prevMessage = message
        }
        runs.append(run)
        return List(runs, id: \.first) { messages in
            MessagesRow(messages: messages, people: self.people, viewer: self.viewer)
        }.navigationBarTitle(Text(space.titleForViewer(viewer, people: people)))
    }
}

struct MessagesRow: View {
    var messages: [Message]
    var people: [Person]
    var viewer: EntityId
    
    var author: EntityId { messages.first!.author }
    var authorName: String {
        if author == viewer {
            return "You"
        }
        let person = people.first { $0.entityId == author }!
        return person.name
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(authorName).foregroundColor(.secondary)
            }
            ForEach(messages) { message in
                Text(message.body).padding(.top, 12.0)
            }
        }
    }
}


struct SpaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        SpaceDetail(space: appData.spaces.first!, people: appData.people, viewer: viewer)
    }
}
