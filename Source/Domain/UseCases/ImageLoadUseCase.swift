//
//  ImageLoadUseCase.swift
//  WWDCast
//
//  Created by Maksym Shcheglov on 09/04/2018.
//  Copyright © 2018 Maksym Shcheglov. All rights reserved.
//

import UIKit
import RxSwift

extension UIImage {
    func forceLazyImageDecompression() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        self.draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        return self
    }
}

protocol ImageLoadUseCaseType {

    ///
    func loadImage(for url: URL) -> Observable<UIImage>
}

class ImageLoadUseCase: ImageLoadUseCaseType {

    private let reachability: ReachabilityServiceType

    init(reachability: ReachabilityServiceType) {
        self.reachability = reachability
        // cost is approx memory usage
        let MB = 1024 * 1024
        _imageDataCache.totalCostLimit = 10 * MB
        _imageCache.countLimit = 20
    }

    // 1st level cache
    private let _imageCache = NSCache<AnyObject, AnyObject>()

    // 2nd level cache
    private let _imageDataCache = NSCache<AnyObject, AnyObject>()

    let loadingImage = ActivityIndicator()

    private func decodeImage(_ imageData: Data) -> Observable<UIImage> {
        return Observable.just(imageData)
            .map { data in
                guard let image = UIImage(data: data) else {
                    return UIImage()
                }
                return image.forceLazyImageDecompression()
        }
    }

    private func _imageFromURL(_ url: URL) -> Observable<UIImage> {
        return Observable.deferred {
            let maybeImage = self._imageCache.object(forKey: url as AnyObject) as? UIImage

            let decodedImage: Observable<UIImage>

            // best case scenario, it's already decoded an in memory
            if let image = maybeImage {
                decodedImage = Observable.just(image)
            }
            else {
                let cachedData = self._imageDataCache.object(forKey: url as AnyObject) as? Data

                // does image data cache contain anything
                if let cachedData = cachedData {
                    decodedImage = self.decodeImage(cachedData)
                }
                else {
                    // fetch from network
                    decodedImage = URLSession.shared.rx.data(request: URLRequest(url: url))
                        .do(onNext: { data in
                            self._imageDataCache.setObject(data as AnyObject, forKey: url as AnyObject)
                        })
                        .flatMap(self.decodeImage)
                        .trackActivity(self.loadingImage)
                }
            }

            return decodedImage.do(onNext: { image in
                self._imageCache.setObject(image, forKey: url as AnyObject)
            })
        }
    }

    /**
     Service that tries to download image from URL.

     In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
     available.

     After image is successfully downloaded, sequence is completed.
     */
    func loadImage(for url: URL) -> Observable<UIImage> {
        return _imageFromURL(url)
            .retryOnBecomesReachable(UIImage(), reachabilityService: self.reachability)
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }

}
