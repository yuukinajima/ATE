//
//  SwiftUIView.swift
//  Ex
//
//  Created by yuki najima on 2024/04/25.
//

import SwiftUI
import SwiftData

struct SwiftUIView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


struct DebugView: View {
    var body: some View {
        TabView {
            RuleView()
                .tabItem {
                    Label("Rule", systemImage: "list.dash")
                }


            VisitUrlView()
                .tabItem {
                    Label("VisitUrl", systemImage: "square.and.pencil")
                }

            LogView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }

        }
    }
}


let firstSectionMessage = """
This section is debug message zone.

"""

struct RuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rules: [Rule]
    var body: some View {

        VStack{
            GroupBox(label:
                Label("Note", systemImage: "info.bubble")
            ) {
                    Text("List of Rules")
            }

            HStack(){
                Button(action: addLog) {
                    Label("Add", systemImage: "plus")
                }
                Button(action: clearLog) {
                    Label("Clear", systemImage: "clear")
                }
            }


            Table(rules){
                TableColumn("timestamp") { item in
                    Text(item.timestamp, format: .dateTime)
                }
            }
        }
    }


    private func addLog() {

    }

    private func clearLog() {

    }
}

struct VisitUrlView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var urls: [VisitedUrl]
    var body: some View {

        VStack{
            GroupBox(label:
                Label("Note", systemImage: "info.bubble")
            ) {
                    Text("VisitUrlView")
            }

            HStack(){
                Button(action: addLog) {
                    Label("Add", systemImage: "plus")
                }
                Button(action: clearLog) {
                    Label("Clear", systemImage: "clear")
                }
            }


            Table(urls){
                TableColumn("timestamp") { item in
                    Text(item.timestamp, format: .dateTime)
                }
            }
        }
    }


    private func addLog() {

    }

    private func clearLog() {

    }
}

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logs: [SafariExtensionLog]
    @Query private var items: [Item]
    @Query private var urls: [VisitedUrl]
    var body: some View {
        
        VStack{
            GroupBox(label:
                Label("Note", systemImage: "info.bubble")
            ) {
                    Text(firstSectionMessage)
                        .font(.footnote)

            }

            HStack(){
                Button(action: addLog) {
                    Label("Add Log", systemImage: "plus")
                }
                Button(action: clearLog) {
                    Label("Clear Log", systemImage: "clear")
                }
            }


            Table(logs){
                TableColumn("message") { log in
                    Text(log.message)
                }
                TableColumn("timestamp") { log in
                    Text(log.timestamp, format: .dateTime)
                }
            }
        }
    }


    private func addLog() {
        withAnimation {
            let newLog = SafariExtensionLog(message: "test")
            modelContext.insert(newLog)
            print(newLog)
            do {
                try modelContext.save()
                print("test")
            }
            catch{
                print("addItem save error")
            }
        }
    }

    private func clearLog() {
        withAnimation {
            do {
                try modelContext.delete(model: SafariExtensionLog.self)
            }
            catch{

            }
        }
    }
}


#Preview {
    SwiftUIView()
        .modelContainer(for: Item.self, inMemory: true)
}


#Preview("Debug") {
    DebugView()
        .modelContainer(for: [
            SafariExtensionLog.self,
            VisitedUrl.self,
            SafariExtensionLog.self,
            Rule.self
        ], inMemory: true)
}
