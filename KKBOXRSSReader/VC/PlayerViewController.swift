//
//  PlayerViewController.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/21.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

class PlayerViewController: UIViewController {
    let bag = DisposeBag()
    
    var epImgView: UIImageView!
    var titleTxtView: UITextView!
    // playerControlView should init before VDL due to the usage of its vm.
    let playerControlView = PlayerControlView()

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        
        bindModel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        epImgView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(12.0)
            make.left.equalTo(view).offset(12.0)
            make.width.height.equalTo(view.bounds.width - 24.0)
        }
        
        titleTxtView.snp.makeConstraints { (make) in
            let offset: CGFloat
            let smallScreenSizeModels = ["iPhone 6s", "iPhone SE", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)"]
            if smallScreenSizeModels.contains(UIDevice.modelName) {
                offset = 12.0
            } else {
                offset = 30.0
            }
            make.top.equalTo(epImgView.snp.bottom).offset(offset)
            make.left.right.equalTo(epImgView)
            make.height.equalTo(70.0)
        }
        
        playerControlView.snp.makeConstraints { (make) in
            make.left.right.equalTo(epImgView)
            make.height.equalTo(180.0)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
    }

    func bindModel() {        
        playerControlView.vm.currentIdx.subscribe(onNext: { [weak self] (currentIdx) in
            guard let strongSelf = self, currentIdx < strongSelf.playerControlView.vm.eps.count else { return }
            let ep = strongSelf.playerControlView.vm.eps[currentIdx]
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                let len = strongSelf.view.bounds.width - 24.0
                let resizing = ResizingImageProcessor(referenceSize: CGSize(width: len, height: len), mode: .aspectFit)
                strongSelf.epImgView.kf.setImage(with: ep.imgURL, placeholder: UIIMAGEVIEW_DEFAULT_IMAGE, options: [.processor(resizing)], progressBlock: nil)
                
                strongSelf.titleTxtView.text = ep.title
            }
            
            if let navVC = self?.presentingViewController as? UINavigationController, let epInfoVC = navVC.viewControllers.last as? EpisodeInfoViewController {
                epInfoVC.vcvm.currentIdx.accept(currentIdx)
            }
        }).disposed(by: bag)
    }
    
    func configView() {
        view.backgroundColor = .white
        epImgView = UIImageView()
        view.addSubview(epImgView)
        titleTxtView = UITextView()
        titleTxtView.font = .systemFont(ofSize: 18.0)
        view.addSubview(titleTxtView)
//        playerControlView = PlayerControlView()
        view.addSubview(playerControlView)
        
        #if targetEnvironment(simulator)
        epImgView.backgroundColor = .green
        titleTxtView.backgroundColor = .green
        playerControlView.backgroundColor = .brown
        #endif
    }

}
