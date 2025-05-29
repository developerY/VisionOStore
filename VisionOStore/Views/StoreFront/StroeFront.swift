//
//  StroeFront.swift
//  VisionOStore
//
//  Created by Siamak Ashrafi on 5/29/25.
//
import SwiftUI
import SwiftData

// MARK: - SwiftData Model
@Model
class Product {
    var id = UUID()
    var name: String
    var productDescription: String  // <-- renamed from description
    var price: Double
    var category: String
    var imageName: String

    init(name: String, productDescription: String, price: Double, category: String, imageName: String) {
        self.name = name
        self.productDescription = productDescription
        self.price = price
        self.category = category
        self.imageName = imageName
    }
}


// MARK: - Main View
struct StorefrontView: View {
    @Query var products: [Product]

    var body: some View {
        NavigationSplitView {
            List(productCategories, id: \String.self) { category in
                NavigationLink(category, value: category)
            }
            .navigationTitle("Categories")
        } detail: {
            ProductListView()
        }
    }

    var productCategories: [String] {
        Array(Set(products.map { $0.category })).sorted()
    }
}

// MARK: - Product List
struct ProductListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Product]
    @Environment(\.navigationSplitViewColumnVisibility) private var columnVisibility
    @State private var selectedCategory: String?

    var body: some View {
        VStack {
            if let selectedCategory = selectedCategory {
                List(filteredProducts(for: selectedCategory), id: \Product.id) { product in
                    NavigationLink(value: product) {
                        HStack {
                            Image(product.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.headline)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .navigationTitle(selectedCategory)
            } else {
                Text("Select a category")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            columnVisibility = .doubleColumn
        }
        .onChange(of: columnVisibility) { newValue in
            if newValue == .singleColumn {
                selectedCategory = nil
            }
        }
        .navigationDestination(for: String.self) { category in
            ProductListView(selectedCategory: category)
        }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
    }

    func filteredProducts(for category: String) -> [Product] {
        products.filter { $0.category == category }
    }
}

// MARK: - Product Detail
struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack(spacing: 16) {
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(product.name)
                .font(.largeTitle)
                .bold()

            Text("$\(product.price, specifier: "%.2f")")
                .font(.title2)
                .foregroundStyle(.accent)

            Text(product.description)
                .padding()

            Spacer()
        }
        .padding()
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    let previewContainer = try! ModelContainer(for: Product.self, configurations: .init(isStoredInMemoryOnly: true))

    let sampleProducts = [
        Product(name: "VisionPro", description: "Next-gen AR glasses.", price: 3499.00, category: "Tech", imageName: "visionPro"),
        Product(name: "AirPods Pro", description: "Active noise cancellation.", price: 249.00, category: "Tech", imageName: "airpods"),
        Product(name: "SwiftUI Handbook", description: "Comprehensive guide to SwiftUI.", price: 39.99, category: "Books", imageName: "swiftuiBook"),
        Product(name: "Yoga Mat", description: "Eco-friendly yoga mat.", price: 59.00, category: "Fitness", imageName: "yogaMat")
    ]

    Task { @MainActor in
        sampleProducts.forEach(previewContainer.mainContext.insert)
    }

    return StorefrontView()
        .modelContainer(previewContainer)
}

