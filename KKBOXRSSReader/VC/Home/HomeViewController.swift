//
//  HomeViewController.swift
//  KKBOXRSSReader
//
//  Created by CHIU PO-SHENG on 2021/1/19.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher

class HomeViewController: UIViewController {
    let vcvm = HomeVCVM()
    let bag = DisposeBag()
    
    var epTbl: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        
        bindModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        epTbl.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.snp.bottomMargin)
        }
    }
    
    func configView() {
        epTbl = UITableView()
        epTbl.delegate = self
        epTbl.register(EpisodeTableViewCell.self, forCellReuseIdentifier: EpisodeTableViewCell.id)
        view.addSubview(epTbl)
        
        #if targetEnvironment(simulator)
        epTbl.backgroundColor = .green
        #endif
    }
    
    func bindModel() {
        vcvm.channelImgURL.asObservable().subscribe(onNext: { [weak self] (url) in
            DispatchQueue.main.async {
                guard let _ = url, let epTbl = self?.epTbl, let _ = self?.tableView(epTbl, viewForHeaderInSection: 0) as? UIImageView else { return }
            }
        }).disposed(by: bag)
        
        vcvm.eps.asObservable().bind(to: epTbl.rx.items(cellIdentifier: EpisodeTableViewCell.id, cellType: EpisodeTableViewCell.self)) { (row, ep, cell) in
            cell.config(episode: ep)
        }.disposed(by: bag)
        
        epTbl.rx.modelSelected(Episode.self).subscribe(onNext: { [weak self] (ep) in
            DispatchQueue.main.async {
                guard let strongSelf = self, let selectedRow = strongSelf.epTbl.indexPathForSelectedRow else { return }
                
                strongSelf.epTbl.deselectRow(at: selectedRow, animated: false)
                
                let epInfoVC = EpisodeInfoViewController()
                epInfoVC.vcvm.channelName = strongSelf.vcvm.channelName
                epInfoVC.vcvm.eps = Array(strongSelf.vcvm.eps.value[0...selectedRow.row])
                epInfoVC.vcvm.currentIdx.accept(selectedRow.row)
                self?.navigationController?.pushViewController(epInfoVC, animated: true)
            }
        }).disposed(by: bag)

    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.width * 9.0 / 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: view.frame.width * 9.0 / 16.0))
        guard let url = vcvm.channelImgURL.value else {
            return header
        }
        let headerResizing = ResizingImageProcessor(referenceSize: CGSize(width: epTbl.frame.width, height: epTbl.frame.width * 9.0 / 16.0), mode: .aspectFit)
        header.kf.setImage(with: url, placeholder: UIIMAGEVIEW_DEFAULT_IMAGE, options: [.processor(headerResizing)], progressBlock: nil)
        
        return header
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    
}
