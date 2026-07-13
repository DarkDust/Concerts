//
//  ImageManager.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-07-13.
//

import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif


/// Helper class to get random images.
final
class ImageManager: Sendable {
    
    /// Category to pick an image from.
    enum Category {
        /// Image of a band.
        case band
        /// Image of a venue.
        case venue
        /// Miscellaneous image.
        case misc
    }
    
    /// URLs of all known images.
    private
    let urls: [Category: [URL]]
    
    
    /// Singleton instance.
    ///
    /// There's not much to gain from passing this via the environment instead, IMHO.
    /// But with a singleton accessory it's a more convenient to use.
    static let instance = ImageManager()
    
    
    private
    init() {
        let bundle = Bundle.main
        guard let resourceURL = bundle.resourceURL else {
            fatalError("No resource URL")
        }
        
        let imagesDirectory = resourceURL.appendingPathComponent("Images")
        let bandURL = imagesDirectory.appendingPathComponent("Bands")
        let venueURL = imagesDirectory.appendingPathComponent("Venues")
        let miscURL = imagesDirectory.appendingPathComponent("Misc")
        
        var urls: [Category: [URL]] = [:]
        let fileManager = FileManager.default
        
        // This is supposed to be static data that has to be there. It's a hard error if this fails,
        // so allow `try!` here.
        // swiftlint:disable force_try
        urls[.band] = try! fileManager.contentsOfDirectory(
            at: bandURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        urls[.venue] = try! fileManager.contentsOfDirectory(
            at: venueURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        urls[.misc] = try! fileManager.contentsOfDirectory(
            at: miscURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        // swiftlint:enable force_try

        self.urls = urls
        assert(!urls[.band]!.isEmpty)
        assert(!urls[.venue]!.isEmpty)
        assert(!urls[.misc]!.isEmpty)
    }
    
    
    /// Get URL to a random image.
    ///
    /// - parameter category: Category to pick an image from. If missing, picks a random image from a random category.
    func randomImageURL(in category: Category?) -> URL {
        let resolvedCategory: Category
        if let category {
            resolvedCategory = category
        } else {
            switch Int.random(in: 0..<3) {
            case 0: resolvedCategory = .band
            case 1: resolvedCategory = .venue
            default: resolvedCategory = .misc
            }
        }
        
        let urls = self.urls[resolvedCategory]!
        return urls.randomElement()!
    }
    
    
    /// Get a random image.
    ///
    /// - parameter category: Category to pick an image from. If missing, picks a random image from a random category.
    func randomImage(in category: Category?) -> Image {
        let url = self.randomImageURL(in: category)
        
        #if canImport(AppKit)
            // This must always succeed, deliberate force unwrap.
            let rawImage = NSImage(contentsOf: url)!
            return Image(nsImage: rawImage)
        #else
            // This must always succeed, deliberate force unwrap.
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
            let rawImage = UIImage(cgImage: cgImage)
            return Image(uiImage: rawImage)
        #endif
    }
}
