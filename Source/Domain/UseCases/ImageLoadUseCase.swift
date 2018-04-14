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

    private let network: NetworkServiceType
    private let reachability: ReachabilityServiceType

    init(network: NetworkServiceType, reachability: ReachabilityServiceType) {
        self.network = network
        self.reachability = reachability
    }

    // 1st level cache, that contains decoded img
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 20
        return cache
    }()

    // 2nd level cache, that contains raw img data
    private lazy var imageDataCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        let MB = 1024 * 1024
        cache.totalCostLimit = 10 * MB // cost is approx memory usage
        return cache
    }()

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

    private func imageFromURL(_ url: URL) -> Observable<UIImage> {
        return Observable.deferred {
            let decodedImage: Observable<UIImage>
            // best case scenario, it's already decoded an in memory
            if let image = self.imageCache.object(forKey: url as AnyObject) as? UIImage {
                decodedImage = Observable.just(image)
            } else if let cachedData = self.imageDataCache.object(forKey: url as AnyObject) as? Data {
                // image data cache contain data
                decodedImage = self.decodeImage(cachedData)
            } else {
                // fetch from network
                let resource = Resource<Data>(url: url)
                decodedImage = self.network.load(resource)
                    .do(onNext: { data in
                        self.imageDataCache.setObject(data as AnyObject, forKey: url as AnyObject)
                    })
                    .flatMap(self.decodeImage)
                    .trackActivity(self.loadingImage)
            }

            return decodedImage.do(onNext: { image in
                self.imageCache.setObject(image, forKey: url as AnyObject)
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
        return imageFromURL(url)
            .retryOnBecomesReachable(UIImage(), reachabilityService: self.reachability)
            .subscribeOn(Scheduler.backgroundWorkScheduler)
            .observeOn(Scheduler.mainScheduler)
    }

}
