//
//  UITextView+AdjustHeight.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/21.
//

import Foundation
import UIKit

extension UITextView {
    func adjustHeight() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }
}
