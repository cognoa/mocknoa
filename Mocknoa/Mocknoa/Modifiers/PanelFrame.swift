//
//  PanelFrame.swift
//  Mocknoa
//
//  Created by Wilma Rodriguez on 2/17/22.
//

import SwiftUI

struct PanelFrame: ViewModifier {
    internal var minWidth: CGFloat
    internal var idealWidth: CGFloat
    internal var minHeight: CGFloat
    internal var idealHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth,
                   idealWidth: idealWidth,
                   maxWidth: .infinity,
                   minHeight: minHeight,
                   idealHeight: idealHeight,
                   maxHeight: .infinity)
    }
}

extension View {
    func panelFrame(minWidth: CGFloat    = 600,
                    idealWidth: CGFloat  = 800,
                    minHeight: CGFloat   = 400,
                    idealHeight: CGFloat = 600) -> some View {
        modifier(PanelFrame(minWidth: minWidth,
                            idealWidth: idealWidth,
                            minHeight: minHeight,
                            idealHeight: idealHeight))
    }
}
