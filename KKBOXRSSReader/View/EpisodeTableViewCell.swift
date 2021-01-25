//
//  EpisodeTableViewCell.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/19.
//

import UIKit
import Kingfisher

class EpisodeTableViewCell: UITableViewCell {
    
    static let id = "EpisodeTableViewCellIdentifier"
    static let resizing66 = ResizingImageProcessor(referenceSize: CGSize(width: 66.0, height: 66.0), mode: .aspectFit)
    
    var imgView: UIImageView!
    var titleTxtView: UITextView!
    var pubDateLbl: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(66.0)
            make.centerY.equalTo(self)
            make.left.equalTo(6.0)
        }
        
        titleTxtView.snp.makeConstraints { (make) in
            make.top.equalTo(imgView).offset(4.0)
            make.left.equalTo(imgView.snp.right).offset(10.0)
            make.height.equalTo(40.0)
            make.right.equalTo(self).inset(6.0)
        }
        
        pubDateLbl.snp.makeConstraints { (make) in
            make.left.equalTo(titleTxtView)
            make.height.equalTo(20.0)
            make.bottom.equalTo(self).inset(6.0)
            make.width.equalTo(120.0)
        }
    }
    
    private func configView() {
        imgView = UIImageView()
        addSubview(imgView)
        
        titleTxtView = UITextView()
        titleTxtView.backgroundColor = .clear
        addSubview(titleTxtView)
        
        pubDateLbl = UILabel()
        pubDateLbl.font = .systemFont(ofSize: 10.0)
        addSubview(pubDateLbl)
        
        #if targetEnvironment(simulator)
        imgView.backgroundColor = .blue
        titleTxtView.backgroundColor = .brown
        pubDateLbl.backgroundColor = .systemPink
        #endif
    }
    
    func config(episode: Episode) {
        pubDateLbl.text = episode.pubDateString()
        titleTxtView.text = episode.title
        imgView.kf.setImage(with: episode.imgURL, placeholder: UIIMAGEVIEW_DEFAULT_IMAGE, options: [.processor(EpisodeTableViewCell.resizing66)], progressBlock: nil)
    }

}
