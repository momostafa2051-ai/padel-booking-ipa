import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CourtsView()
                .tabItem {
                    Image(systemName: "sportscourt")
                    Text("الملاعب")
                }
                .tag(0)
            
            MyBookingsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("حجوزاتي")
                }
                .tag(1)
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}