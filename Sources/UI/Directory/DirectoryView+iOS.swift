//
//  DirectoryView+iOS.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-07-13.
//

#if canImport(UIKit)
import SwiftUI
import UIKit

/// Stupid hack to find the `UISplitViewController` and remove its background.
struct SplitViewBackgroundRemover: UIViewRepresentable {
    
    let name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        removeBackground(view: view)
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        removeBackground(view: view)
    }
    
}

private
extension SplitViewBackgroundRemover {
    
    func removeBackground(view: UIView) {
        DispatchQueue.main.async {
            let root = findRootView(of: view)
            traverseViewHierarchy(from: root)
        }
    }
    
    func traverseViewHierarchy(from view: UIView) {
        if let controller = view.enclosingViewController() {
            if controller is UISplitViewController
            || controller.debugDescription.contains("NavigationStackHostingController") {
                controller.view.backgroundColor = .clear
            }
        }
        
//        if view.debugDescription.contains("NavigationBarPlatterContainer") {
//            view.backgroundColor = UIColor.systemGroupedBackground.withAlphaComponent(0.8)
//        }
        
        for subview in view.subviews {
            traverseViewHierarchy(from: subview)
        }
    }
    
    func findRootView(of view: UIView) -> UIView {
        var cursor = view
        while let superview = cursor.superview {
            cursor = superview
        }
        return cursor
    }
    
}


private
extension UIView {
    
    func enclosingViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let viewController = next as? UIViewController {
                return viewController
            }
            responder = next
        }
        return nil
    }
    
}
#endif
