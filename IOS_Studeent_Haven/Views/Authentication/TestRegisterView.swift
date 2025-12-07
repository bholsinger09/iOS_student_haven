import SwiftUI

/// Simple test view to debug RegisterView
struct TestRegisterView: View {
    var body: some View {
        ZStack {
            // Purple Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple,
                    Color.blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Test Register View")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("If you see this, the view is rendering")
                    .foregroundColor(.white)
            }
        }
    }
}
