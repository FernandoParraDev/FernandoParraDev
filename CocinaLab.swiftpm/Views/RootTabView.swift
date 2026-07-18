import SwiftUI

enum RootTab: Hashable {
    case recetas
    case pruebas
}

/// App root: a published-recipes library and a separate "kitchen lab" tab
/// where recipes are experimented on node-by-node before publishing.
struct RootTabView: View {
    @State private var selectedTab: RootTab = .recetas
    @State private var publishedPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            RecipeListView(path: $publishedPath)
                .tabItem { Label("Recetas", systemImage: "fork.knife") }
                .tag(RootTab.recetas)

            KitchenTestsListView(publishedPath: $publishedPath, selectedTab: $selectedTab)
                .tabItem { Label("Pruebas de cocina", systemImage: "testtube.2") }
                .tag(RootTab.pruebas)
        }
    }
}
