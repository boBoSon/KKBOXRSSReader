//
//  EpisodeInfoViewController.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/21.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

class EpisodeInfoViewController: UIViewController {
    let vcvm = EpisodeInfoVCVM()
    let bag = DisposeBag()
    
    var scrollView: UIScrollView!
    var channelNameLbl: UILabel!
    var epTitleTxtView: UITextView!
    var epImgView: UIImageView!
    var descTxtView: UITextView!
    var playBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        configView()

        bindModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        epImgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(12.0)
            make.width.height.equalTo(view.bounds.width - 24.0)
        }
        
        channelNameLbl.snp.makeConstraints { (make) in
            make.left.equalTo(epImgView).offset(20.0)
            make.top.equalTo(epImgView).offset(40.0)
            make.width.equalTo(100.0)
            make.height.equalTo(50.0)
        }
        
        epTitleTxtView.snp.makeConstraints { (make) in
            make.left.equalTo(channelNameLbl)
            make.right.equalTo(epImgView).inset(20.0)
            make.top.equalTo(channelNameLbl.snp.bottom).offset(20.0)
            make.height.equalTo(150.0)
        }
        
        descTxtView.snp.makeConstraints { (make) in
            make.left.right.equalTo(epImgView)
            make.top.equalTo(epImgView.snp.bottom).offset(8.0)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descTxtView.snp.bottom).offset(20.0)
            make.width.height.equalTo(100.0)
            make.centerX.equalTo(scrollView)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewContentHeight()
    }
    
    func configView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)
        epImgView = UIImageView()
        scrollView.addSubview(epImgView)
        channelNameLbl = UILabel()
        channelNameLbl.font = .boldSystemFont(ofSize: 20.0)
        channelNameLbl.text = vcvm.channelName
        scrollView.addSubview(channelNameLbl)
        epTitleTxtView = UITextView()
        epTitleTxtView.font = .systemFont(ofSize: 18.0)
        epTitleTxtView.textColor = .darkGray
        epTitleTxtView.backgroundColor = .clear
        scrollView.addSubview(epTitleTxtView)
        descTxtView = UITextView()
        descTxtView.font = .systemFont(ofSize: 14.0)
        descTxtView.textColor = .darkGray
        descTxtView.backgroundColor = .clear
        scrollView.addSubview(descTxtView)
        playBtn = UIButton()
        playBtn.setImage(UIImage(named: "Play"), for: .normal)
        scrollView.addSubview(playBtn)
        
        #if targetEnvironment(simulator)
        epImgView.backgroundColor = .green
        channelNameLbl.backgroundColor = .purple
        epTitleTxtView.backgroundColor = .red
        playBtn.backgroundColor = .yellow
        #endif
    }
    
    private func updateScrollViewContentHeight() {
        scrollView.contentSize.height = descTxtView.frame.maxY + 136.0
    }
    
    func bindModel() {
        vcvm.currentIdx.subscribe(onNext: { [weak self] (currentIdx) in
            DispatchQueue.main.async {
                guard let strongSelf = self, currentIdx < strongSelf.vcvm.eps.count else { return }
                let ep = strongSelf.vcvm.eps[currentIdx]
                strongSelf.epTitleTxtView.text = ep.title
                strongSelf.descTxtView.text = ep.desc
                strongSelf.descTxtView.adjustHeight()
                let len = strongSelf.view.bounds.width - 24.0
                let resizing = ResizingImageProcessor(referenceSize: CGSize(width: len, height: len), mode: .aspectFit)
                strongSelf.epImgView.kf.setImage(with: ep.imgURL, placeholder: UIIMAGEVIEW_DEFAULT_IMAGE, options: [.processor(resizing)], progressBlock: nil)
            }
        }).disposed(by: bag)

        playBtn.rx.tap.subscribe(onNext: { [weak self] (_) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                
                let playerVC = PlayerViewController()
                playerVC.playerControlView.vm.setPlayerItems(episodes: strongSelf.vcvm.eps)
                strongSelf.present(playerVC, animated: true, completion: nil)
            }
            
        }).disposed(by: bag)
    }

}
