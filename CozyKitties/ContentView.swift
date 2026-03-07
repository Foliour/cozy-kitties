import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "cat.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to CozyKitties!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
