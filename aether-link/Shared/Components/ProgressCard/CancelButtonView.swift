//
//  CancelButtonView.swift
//  ÆtherL
//
//  Created by Luis Roberto Hernandez Robles on 06/12/24.
//

import SwiftUI

struct CancelButtonView: View {
    var abortOperation: () -> Void

    var body: some View {
        Button(action: {
            abortOperation()
        }) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .font(.headline)
                Text("Cancel")
                    .fontWeight(.semibold)
            }
            .foregroundColor(Color.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("DangerRed"))
            .cornerRadius(12)
            .shadow(color: Color("DangerRed").opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .accessibility(label: Text("Cancel Operation"))
    }
}
