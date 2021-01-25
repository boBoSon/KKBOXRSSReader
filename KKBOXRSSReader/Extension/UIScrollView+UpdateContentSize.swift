//
//  UIScrollView+UpdateContentSize.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/22.
//

import Foundation
import UIKit

extension UIScrollView {
    func updateContentSize() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}
