//
//  SearchFieldWithDebounce.swift
//  UniversalMap
//
//  Created by Володимир on 13.09.2025.
//

import SwiftUI

struct SearchFieldWithDebounce: View {
    @State private var searchFieldText: String = ""
    @State private var debouncedTask: Task<Void, Never>?
    
    @ObservedObject var viewModel: MapLinkViewModel
    
    var body: some View {
        TextField("Search...", text: $searchFieldText)
            .onChange(of: searchFieldText) { newValue in
                debouncedTask?.cancel()

                debouncedTask = Task {
                    do {
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                        
                        if !Task.isCancelled {
                            performSearch(query: newValue)
                        }
                    } catch {
                        print("Task was cancelled")
                    }
                }
            }
    }

    private func performSearch(query: String) {
        if !query.isEmpty {
            viewModel.performSearch(query: query)
        }
    }
}

#Preview {
    SearchFieldWithDebounce(viewModel: MapLinkViewModel())
        .padding()
}
