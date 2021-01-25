//
//  EpisodeInfoVCVM.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/21.
//

import Foundation
import RxCocoa
import RxSwift

class EpisodeInfoVCVM: NSObject {
    var channelName: String?    
    var eps = [Episode]()
    var currentIdx: BehaviorRelay<Int> = BehaviorRelay(value: 0)
}
