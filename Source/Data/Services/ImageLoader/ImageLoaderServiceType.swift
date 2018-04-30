//
//  ImageLoaderServiceType.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 30/04/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

protocol ImageLoaderServiceType {

    /// Loads image for given url
    ///
    /// - Parameter url: the url to load image for
    /// - Returns: the observable image object
    func loadImage(for url: URL) -> Observable<UIImage>
}
