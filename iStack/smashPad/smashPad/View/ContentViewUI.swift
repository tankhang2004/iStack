import SwiftUI
import SwiftData

struct ContentViewUI: View {
    let category: Category
    // Keeps the sheet always visible
    @State private var isSheetPresented = true
    @State private var currentDetent: PresentationDetent = .height(214)
    
    var body: some View {
        ZStack {
            // 1. Main Background
            Image("GradientOval1")
            .resizable() //
            .scaledToFill()
            // 2. Main Content
            VStack {
                // Header
                VStack(alignment: .leading, spacing: 42) {
                    Text(category.name)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Spacer()
                        Image(systemName: "heart")
                            .foregroundStyle(Color.indigo)
                        Text("We're quietly paying attention...")
                        Spacer()
                    }
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Punch Counter
                VStack(spacing: 8) {
                    Text("2")
                        .font(.system(size: 80, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("TIMES PILLOW PUNCHED")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.secondary)
                        .tracking(1.5) // Matches the wide letter spacing in the design
                }
                
                Spacer()
                Spacer()
            }
            
            // 3. The Native Bottom Sheet
            .sheet(isPresented: $isSheetPresented) {
                SheetContentView(currentDetent: $currentDetent)
                    .presentationDetents([.height(214), .height(291)], selection: $currentDetent)
                
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color(uiColor: .systemBackground))
                    .presentationCornerRadius(35)
                    .interactiveDismissDisabled()
                // Keeps background normal at small height, dims it at 291
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(214)))
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - The Content Inside the Sheet
struct SheetContentView: View {
    // Accepts the state from the parent view
    @Binding var currentDetent: PresentationDetent
    @State private var isPaused = false
    
    var body: some View {
        VStack {
            // Timer & Icon Row
            HStack {
                Spacer()
                Text("00:10")
                    .font(.system(size: 34, weight: .medium, design: .rounded))
                    .foregroundColor(Color.indigo)
                    .padding(.leading, 50)
                Spacer()
                ConnectivityButton{}
            }
            .padding(.horizontal, 24)
            
            
            // Play/Pause Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.10)) {
                    isPaused.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    if isPaused {
                        currentDetent = .height(291)
                    } else {
                        currentDetent = .height(214)
                    }
                }
            }) {
                Image(systemName: isPaused ? "arrow.clockwise" : "pause")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(isPaused ? Color.indigo.opacity(0.8) : .primary)
                .frame(width: 110, height: 110)
                .background(isPaused ? .indigo.opacity(0.2) : Color.primary.opacity(0.15))
                .clipShape(Circle())
            }
            
            
            
            // END TRACKING BUTTON
            if currentDetent == .height(291) {
                Button(action: {
                    print("End Tracking Tapped")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .fontWeight(.medium)
                        Text("End Session")
                            .font(.system(size: 18, weight: .regular))
                    }
                    .foregroundColor(Color.red)
                    .padding(.vertical, 14)
                    .frame(width: 330)
                    .background(Color.red.opacity(0.14))
                    .clipShape(Capsule())
                }
                .padding(.top, 12)
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    do {
        // 1. Create the temporary memory database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, configurations: config)
        
        // 2. Create the mock category
        let mockCategory = Category(name: "Studying")
        
        // 3. CRUCIAL: Insert it into the database so the View can actually read it!
        container.mainContext.insert(mockCategory)
        
        // 4. Return the View
        return ContentViewUI(category: mockCategory)
            .modelContainer(container)
    } catch {
        return Text("Failed to load preview")
    }
}
