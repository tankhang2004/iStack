//
//  AddCategory.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI
import SwiftData

struct AddCategory: View {
    
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Category.name)
    private var categories: [Category]
    
    @State private var categoryName = ""
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("New Activity")
                .font(.title2.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Activity Name")
                    .foregroundStyle(.secondary)
                
                TextField("e.g. Reading", text: $categoryName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
            }
            
            HStack {
                
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .frame(width: 55)
                        .padding(.horizontal, 20)
                        .frame(height: 46)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .foregroundStyle(.primary)
                Spacer()
                
                Button("Save") {
                    saveCategory()
                }
                .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .foregroundStyle(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? Color.gray
                    : Color(red: 109/255, green: 124/255, blue: 255/255)
                )
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: 340)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(radius: 30)
    }
    
    private func saveCategory() {
        
        let name = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !name.isEmpty else { return }
        
        let alreadyExists = categories.contains {
            $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }
        
        guard !alreadyExists else {
            withAnimation {
                isPresented = false
            }
            return
        }
        
        modelContext.insert(Category(name: name))
        
        withAnimation(.spring(response: 0.35)) {
            isPresented = false
        }
    }
}

#Preview {
    
    ZStack {
        
        Color.black
        
        AddCategory(
            isPresented: .constant(true)
        )
    }
    .preferredColorScheme(.dark)
    .modelContainer(for: Category.self, inMemory: true)
}
