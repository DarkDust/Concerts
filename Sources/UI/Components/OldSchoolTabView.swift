//
//  OldSchoolTabView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-07-12.
//

import SwiftUI

/// A  tab view, like in old UIs which simulated paper tabs.
struct OldSchoolTabView<SelectionValue: Hashable>: View {
    
    /// Tabs to show.
    let tabs: [Tab]
    
    /// Current selection.
    @Binding
    var selection: SelectionValue
    
    /// Color of the outline.
    private
    let lineColor: Color = .primary
    
    /// Color to tint inactive tab backgrounds.
    private
    let inactiveTintColor: Color = .secondary.opacity(0.2)
    
    
    var body: some View {
        GeometryReader {
            (proxy) in
            
            let spacing: CGFloat = 20
            let tabWidth: CGFloat = (proxy.size.width - (CGFloat(tabs.count + 1)) * spacing) / CGFloat(tabs.count)
            
            HStack(spacing: 0) {
                FillView(lineColor: lineColor)
                
                ForEach(tabs) {
                    (tab) in
                    
                    if tabs.firstIndex(of: tab) != 0 {
                        FillView(lineColor: lineColor)
                    }
                    
                    TabView(
                        tab: tab,
                        lineColor: lineColor,
                        inactiveTintColor: inactiveTintColor,
                        selection: $selection
                    )
                    .frame(width: tabWidth)
                }
                
                FillView(lineColor: lineColor)
            }
        }
        .frame(height: 30)
    }
    
    
}


extension OldSchoolTabView {
    
    /// Tab data for the ``OldSchoolTabView``
    struct Tab: Identifiable, Equatable {
        let id: SelectionValue
        let title: String
    }
    
}


private
extension OldSchoolTabView {
    
    /// View for a single tab.
    struct TabView: View {
        
        let tab: Tab
        let lineColor: Color
        let inactiveTintColor: Color
        
        @Binding
        var selection: SelectionValue
        
        @State
        var isPressed: Bool = false
        
        
        var body: some View {
            let isSelected = selection == tab.id
            
            ZStack {
                tabBackground
                
                Text(tab.title)
                    .font(.caption)
                    .bold(isSelected)
                    .padding(.horizontal)
            }
            .scaleEffect(isPressed ? 1.2 : 1, anchor: .top)
            ._onButtonGesture {
                (pressed) in
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressed
                }
            } perform: {
                selection = tab.id
            }
        }
        
        
        var tabBackground: some View {
            let isSelected = selection == tab.id
            
            return GeometryReader {
                (proxy) in
                
                let path = linePath(size: proxy.size)
                
                Color.clear.glassEffect(
                    .regular.tint(tintColor),
                    in: path
                )
                .transition(.opacity)
                path.stroke(lineColor, lineWidth: 1)
                
                if selection != tab.id {
                    let topPath = Path {
                        $0.move(to: .init(x: 0, y: 0.5))
                        $0.addLine(to: .init(x: proxy.size.width, y: 0.5))
                    }
                    topPath.stroke(lineColor, lineWidth: 1)
                }
            }
            .shadow(radius: isSelected ? 2 : 0, y: isSelected ? 2 : 0)
        }
        
        
        var tintColor: Color? {
            if isPressed || selection == tab.id {
                return nil
            }
            
            return inactiveTintColor
        }
        
        
        func linePath(size: CGSize) -> Path {
            // swiftlint:disable identifier_name
            let lineWidth: CGFloat = 1
            let x0: CGFloat = 0
            let x1 = size.height / 2
            let x3 = (size.width)
            let x2 = x3 - x1
            let y0: CGFloat = lineWidth / 2
            let y1 = (size.height - (lineWidth / 2))
            // swiftlint:enable identifier_name

            return Path {
                $0.move(to: .init(x: x0, y: y0))
                $0.addCurve(to: .init(x: x1, y: y1), control1: .init(x: x1, y: y0), control2: .init(x: x0, y: y1))
                $0.addLine(to: .init(x: x2, y: y1))
                $0.addCurve(to: .init(x: x3, y: y0), control1: .init(x: x3, y: y1), control2: .init(x: x2, y: y0))
            }
        }
        
    }
    
    
    /// Draws a horizontal line at the top.
    struct FillView: View {
        
        let lineColor: Color
        
        var body: some View {
            Canvas {
                (context, size) in
                
                // swiftlint:disable identifier_name
                let lineWidth: CGFloat = 1
                let x0: CGFloat = 0
                let x1 = size.width
                let y0: CGFloat = lineWidth / 2
                // swiftlint:enable identifier_name
                
                let path = Path {
                    $0.move(to: .init(x: x0, y: y0))
                    $0.addLine(to: .init(x: x1, y: y0))
                }
                
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }
        }
    }
}


#Preview("Single Tab") {
    let tab = OldSchoolTabView<UUID>.Tab(id: UUID(), title: "Test")
    OldSchoolTabView.TabView(
        tab: tab,
        lineColor: .red,
        inactiveTintColor: .yellow,
        selection: .constant(UUID())
    )
    .frame(height: 30)
}

#Preview("Single Tab Selected") {
    let tab = OldSchoolTabView<UUID>.Tab(id: UUID(), title: "Test")
    
    OldSchoolTabView.TabView(
        tab: tab,
        lineColor: .primary,
        inactiveTintColor: .secondary,
        selection: .constant(tab.id)
    )
    .frame(width: 300, height: 30)
}

#Preview {
    let tab1 = OldSchoolTabView<UUID>.Tab(id: UUID(), title: "Alpha")
    let tab2 = OldSchoolTabView<UUID>.Tab(id: UUID(), title: "Beta")
    
    OldSchoolTabView(tabs: [tab1, tab2], selection: .constant(tab1.id))
}
