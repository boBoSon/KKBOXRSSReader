//
//  HomeVCVM.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/19.
//

import UIKit
import RxCocoa
import RxSwift
import FeedKit

class HomeVCVM: NSObject {
    var channelImgURL: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    var channelName: String?
    var eps: BehaviorRelay<[Episode]> = BehaviorRelay(value: [])
    
    override init() {
        super.init()
        guard let feedURL = URL(string: "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss") else {
            // TODO: Alert
            print("!!! error while fetching rss feed.")
            return
        }
        let parser = FeedParser(URL: feedURL)
        // Parse asynchronously, not to block the UI.
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { [weak self] (result) in
            // Do your thing, then back to the Main thread
            switch result {
            case .success(let feed):
                switch feed {
                case let .rss(feed):
                    guard let items = feed.items else {
                        return
                    }
                    var eps: [Episode] = []
                    for item in items {
                        guard let contentURLStr = item.enclosure?.attributes?.url, let contentURL = URL(string: contentURLStr), let title = item.title, let desc = item.description, let pubDate = item.pubDate, let imgURLStr = item.iTunes?.iTunesImage?.attributes?.href, let imgURL = URL(string: imgURLStr) else {
                            continue
                        }
                        let ep = Episode(title: title, contentURL: contentURL, publishedDate: pubDate, imageURL: imgURL, description: desc)
                        eps.append(ep)
                    }
                    self?.eps.accept(eps)
                    
                    if let imgURLStr = feed.image?.url, let imgURL = URL(string: imgURLStr) {
                        self?.channelImgURL.accept(imgURL)
                    }
                    
                    self?.channelName = feed.title
                default:
                    print(feed)
                }
            case .failure(let error):
                // TODO: Alert
                print("!!! error: \(error)")
            }
        }
    }
}
