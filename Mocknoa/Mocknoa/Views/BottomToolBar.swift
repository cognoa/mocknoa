//
//  BottomToolBar.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/16/22.
//

import SwiftUI

struct BottomToolBar: View {
    @Binding var showNewRow: Bool

    var body: some View {
        Button {
            showNewRow.toggle()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(.all, 2)
        }
        .padding(.all, 4)
        .padding(.horizontal, 2)
    }
}
