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
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "list.dash")
                }
            RuleView()
                .tabItem {
                    Label("Rule", systemImage: "list.dash")
                }

            AutoRuleView()
                .tabItem {
                    Label("AutoRule", systemImage: "list.dash")
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




struct SettingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settings: AppSettings?
    @State private var tag: String = ""
    @State private var location: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                if let settings {


                    HStack(){
                        Text("Tag:")
                        TextField(
                            "tag",
                            text: $tag
                        )
                    }
                    HStack(){
                        Text("Location:")
                        TextField(
                            "location",
                            text: $location
                        )
                    }


                } else {
                    Text("Loading…")
                }
                Button(action: {}) {
                    Label("Save", systemImage: "archivebox")
                }
            }
            .navigationTitle("Singletons")
            .onAppear(perform: load)
        }
    }

    func load() {
        let request = FetchDescriptor<AppSettings>()
        let data = try? modelContext.fetch(request)
        settings = data?.first ?? AppSettings(tag: "work", location: "downloads")
        tag = settings?.tag ?? "a"
        location = settings?.location ?? "w"
    }
}

let firstSectionMessage = """
This section is debug message zone.

"""

struct RuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rules: [Rule]
    @State private var name: String = ""
    @State private var matcher: String = ""

    var body: some View {

        VStack{
            GroupBox(label:
                Label("Note", systemImage: "info.bubble")
            ) {
                TextField(
                    "name",
                    text: $name
                )
                TextField(
                    "matcher",
                    text: $matcher
                )
                
            }

            HStack(){
                Button(action: add) {
                    Label("Add", systemImage: "plus")
                }
                Button(action: clear) {
                    Label("Clear", systemImage: "trash")
                }
            }

            Table(rules){
                TableColumn("id") { item in
                    Text(item.id.uuidString) 
                        .contextMenu {
                            Button(
                                action: {}
                            ) {
                                Text("Edit todo")
                            }

                            Divider()
                            
                            Button(action: {
                                modelContext.delete(item)
                            }) {
                                Text("Delete")
                            }
                      }
                }
                TableColumn("name") { item in
                    Text(item.name)
                }
                TableColumn("matcher") { item in
                    Text(item.matcher)
                }
                TableColumn("timestamp") { item in
                    Text(item.timestamp, format: .dateTime)
                }
            }
        }
    }

    private func add() {
        withAnimation {
            let newItem = Rule(name: $name.wrappedValue, matcher: $matcher.wrappedValue)
            modelContext.insert(newItem)
        }
    }

    private func clear() {
        withAnimation {
            do {
                try modelContext.delete(model: Rule.self)
            }
            catch{
            }
        }
    }

}

struct AutoRuleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rules: [AutoGenerateRule]
    var body: some View {

        VStack{
            GroupBox(label:
                Label("Note", systemImage: "info.bubble")
            ) {
                    Text("List of AutoRules")
            }

            HStack(){
                Button(action: add) {
                    Label("Add", systemImage: "plus")
                }
                Button(action: clear) {
                    Label("Clear", systemImage: "trash")
                }
            }


            Table(rules){
                TableColumn("matcher") { item in
                    Text(item.matcher)
                        .contextMenu {
                            Button(action: {
                                modelContext.delete(item)
                            }) {
                                Text("Delete")
                            }
                        }
                }
                TableColumn("timestamp") { item in
                    Text(item.timestamp, format: .dateTime)
                }
                TableColumn("expiredAt") { item in
                    if let expiredAt = item.expiredAt {
                        Text(expiredAt, format: .dateTime)
                    } else {
                        Text("nil")
                    }

                }
            }
        }
    }

    private func add() {

    }

    private func clear() {
        withAnimation {
            do {
                try modelContext.delete(model: AutoGenerateRule.self)
            }
            catch{
            }
        }
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
                Button(action: add) {
                    Label("Add", systemImage: "plus")
                }
                Button(action: clear) {
                    Label("Clear", systemImage: "trash")
                }
            }


            Table(urls){
                TableColumn("timestamp") { item in
                    Text(item.timestamp, format: .dateTime)
                }
            }
        }
    }


    private func add() {

    }

    private func clear() {
        withAnimation {
            do {
                try modelContext.delete(model: VisitedUrl.self)
            }
            catch{
            }
        }
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
                    Label("Clear Log", systemImage: "trash")
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
            Rule.self,
            AutoGenerateRule.self,
            AppSettings.self
        ], inMemory: true)
}
