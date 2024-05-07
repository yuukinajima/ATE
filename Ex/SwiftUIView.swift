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


struct View1: View {
    var body: some View {
        Text("View 1")
    }
}


let firstSectionMessage = """
This section is debug message zone.

"""


struct DebugView: View {
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


struct NaviView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            View1()
                .tabItem {
                    Label("Setting", systemImage: "list.dash")
                }


            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "square.and.pencil")
                }
        }
    }

}

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        View1()
            .tabItem {
                Label("Menu", systemImage: "list.dash")
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
        ], inMemory: true)
}
