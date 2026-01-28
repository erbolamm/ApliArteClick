import SwiftUI

struct ContentView: View {
    @StateObject private var autoClicker = AutoClicker()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("macOS Auto-Clicker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                Text("Interval (ms)")
                    .font(.headline)
                
                TextField("Interval", value: $autoClicker.interval, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
            }
            .padding(.horizontal)

            Button(action: {
                if autoClicker.isRunning {
                    autoClicker.stop()
                } else {
                    autoClicker.start()
                }
            }) {
                Text(autoClicker.isRunning ? "STOP" : "START")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(autoClicker.isRunning ? Color.red : Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .buttonStyle(.plain)
            
            if !autoClicker.hasPermission {
                Text("⚠️ Permission Required")
                    .foregroundColor(.red)
                    .font(.callout)
                    .onTapGesture {
                        autoClicker.start() // This will trigger the prompt again
                    }
            }

            if autoClicker.isRunning {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("Clicking active...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }

            Spacer()
            
            Text("Note: Accessibility permissions required.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(width: 300, height: 350)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }
}

#Preview {
    ContentView()
}
