//
//  CravingView.swift
//  Nurtra V2
//
//  Created by Giang Michael Dao on 10/27/25.
//

import SwiftUI

struct CravingView: View {
    var body: some View {
        VStack {
            Text("Craving Page")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This is an empty page for cravings")
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
        }
        .navigationTitle("Craving")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CravingView()
    }
}
