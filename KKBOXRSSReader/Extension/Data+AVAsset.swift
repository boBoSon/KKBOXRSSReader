//
//  Data+AVAsset.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/23.
//

import Foundation
import AVFoundation

extension Data {
    func getAVAsset() -> AVAsset? {
        let path = NSHomeDirectory().appending("/Documents/Podcast.mp3")
        unlink(NSString(string: path).utf8String)
        let url = URL(fileURLWithPath: path)
        do {
            try self.write(to: url)
        } catch {
            print(error)
            return nil
        }
        
        return AVAsset(url: url)
    }
        
}
