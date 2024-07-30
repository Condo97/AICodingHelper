import SwiftUI

struct ContentView: View {
    @State private var totalTokens: Int = 0
    @State private var isLoading: Bool = true
    
    // Sample list of file paths
    let filepaths = ["file1.txt", "file2.txt", "file3.txt"]
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Total Tokens: \(totalTokens)")
                    .font(.largeTitle)
            }
        }asdfaaa
        .padding()
        .task {
            await calculateTotalTokens()
        }
    }
    
    func getEstimatedTokens(filepath: String) async -> Int {
        // Simulating some async work with a random token count for demonstration.
        try? await Task.sleep(nanoseconds: 200_000_000) // Simulate async delay
        return Int.random(in: 1...100)  // Replace with actual logic to get token count.
    }
    
    func calculateTotalTokens() async {
        var total = 0

        await withTaskGroup(of: Int.self) { taskGroup in
            for filepath in filepaths {
                taskGroup.addTask {
                    await getEstimatedTokens(filepath: filepath)
                }
            }

            for await tokens in taskGroup {
                total += tokens
            }
        }

        totalTokens = total
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
