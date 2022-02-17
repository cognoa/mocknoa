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
        HStack(alignment: .center) {
            Button {
                showNewRow.toggle()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.white)
                    .padding(.all, 2)
            }
            .aspectRatio(contentMode: .fit)
            .padding(.vertical, 1)
            .padding(.horizontal, 2)
            Spacer()
        }
    }
}
