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
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

extension Space {
    func titleForViewer(_ viewer: EntityId) -> String {
        participants.filter { $0.entityId != viewer }
            .map { $0.name }
            .joined(separator: ", ")
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            SpaceList(spaces: appData.spaces, viewer: viewer)
                .navigationBarTitle(Text("$PX"))
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct SpaceList: View {
    let spaces: [Space]
    let viewer: EntityId
    
    var body: some View {
        List(spaces) { space in
            NavigationLink(destination: SpaceDetail(space: space, viewer: self.viewer)) {
                SpaceRow(space: space, viewer: self.viewer)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Badge: View {
    // show even if count is zero
    let alwaysShow: Bool = false
    var count: Int = 0
    
    var body: some View {
        Group {
            if count > 0 || alwaysShow {
                Text("\(count)")
                    .font(.callout)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 6.0)
                    .background(Color(UIColor.link))
                    .cornerRadius(14.0)
            }
        }
    }
}

struct SpaceRow: View {
    let space: Space
    let viewer: EntityId
    
    var body: some View {
        HStack {
            Text(space.titleForViewer(self.viewer))
            Spacer()
            Badge(count: space.unreadCount)
        }
    }
}

struct SpaceDetail: View {
    let space: Space
    let viewer: EntityId

    lazy var title: String = {
        space.titleForViewer(viewer)
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
        return ScrollView {
            ForEach(runs, id: \.first) { messages in
                MessagesRow(messages: messages, viewer: self.viewer)
            }.padding()
        }.navigationBarTitle(Text(space.titleForViewer(viewer)))
    }
}

struct MessagesRow: View {
    let messages: [Message]
    let viewer: EntityId
    
    var authorName: String { messages.first!.author.name }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(authorName)
                Spacer()
                Text(dateFormatter.string(from: self.messages.first!.sentAt))
            }.font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical, 6.0)
            ForEach(messages) { message in
                MessageBody(message: message)
                    .padding(.bottom, 12.0)
            }
        }
    }
}

struct MessageBody: View {
    @State var message: Message
    @State var rectFrame: CGRect = .zero
    
    var body: some View {
        TextView(text: $message.body)
            .frame(rectFrame)
            .onPreferenceChange(MyPrefKey.self) {
                self.rectFrame = $0
            }
    }
}

struct MyPrefKey: PreferenceKey {
    typealias Value = CGRect

    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.text = text
        myTextView.sizeToFit()
        self.height = myTextView.frame.height
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
//        myTextView.isScrollEnabled = false
//        myTextView.textContainer.lineBreakMode = .byWordWrapping
        myTextView.isUserInteractionEnabled = true

        return myTextView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
//        textView.text = text
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            print("text now: \(String(describing: textView.text!))")
            self.parent.text = textView.text
        }
    }
}

struct SpaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        SpaceDetail(space: appData.spaces.first!, viewer: viewer)
    }
}
