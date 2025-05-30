//
//  VisionOStoreApp.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/28/25.
//

import SwiftUI
import SwiftData
import OSLog

let logger = Logger(subsystem: "com.yourcompany.app", category: "Data")


@main
struct VisionOStoreApp: App {

    @State private var appModel = AppModel()
    
    
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                DataExampleItem.self, // Example Data
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
    
    init() {
        // only insert if the store is empty
        let ctx = sharedModelContainer.mainContext
        let existing: [ProductSplit] = (try? ctx.fetch(FetchDescriptor<ProductSplit>())) ?? []
        if existing.isEmpty {
            sampleProductsSplit.forEach { ctx.insert($0) }
        }
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .modelContainer(sharedModelContainer)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

extension ModelContext {
    func dumpAllProducts() {
        do {
            let all: [ProductSplit] = try fetch(FetchDescriptor<ProductSplit>())
            logger.info("⛓️ ⁨Found \(all.count) products⁩")
            for p in all {
                logger.info("• \(p.name)") // — $\(String(format: \"%.2f\", p.price))")
            }
        } catch {
            logger.error("Failed to fetch products: \(error.localizedDescription)")
        }
    }
}
