//
//  FullScreenImgWithThumbsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/20.
//
//
//  💬 FullScreenImgWithThumbsVc
//  여러개의 이미지들을 한장씩 전체화면으로 표시.
//  하단에 썸네일 목록을 표시하고 썸네일을 선택하면
//  해당이미지가 전체화면에 표시됨.

import UIKit

class FullScreenImgWithThumbsVc: UIViewController {

    @IBOutlet weak var board: UIView!           // 전체화면에 표시될 이미지의 parent
    @IBOutlet weak var stack: UIStackView!      // 썸네일 이미지들이 표시될 stack view
    @IBOutlet weak var thumbsSv: UIScrollView!  // 썸네일 이미지들이 표시될 scroll view

    let imgTag: Int = 11
    var imgUrls: [String] = []      // 표시될 이미지들의 url
    var imgDatas: [Data?] = []      // 표시될 이미지들의 data
    var selectedImgIndex: Int = 0   // 현재 선택된 이미지의 인덱스
    var loadCount: Int = 0          // 현재 로드된 이미지의 수 (url로 불러올때)
    var imgSv: UIScrollView!        // 전체화면에 표시될 이미지를 담는 scroll view (페이징 효과 적용)
    var thumbs: [FullScreenImgThumb] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.configure()
        }
    }
    
    func configure() {
        thumbsSv.decelerationRate = .fast
        
        // 이미지 데이터로 이미지 생성
        if imgDatas.count > 0 {
            setScrollview()
            setExitButton()
            self.createCells(imgDatas: imgDatas)
            return
        }
        
        // show indicator
        if imgUrls.count > 0 { _ = _utils.createIndicator() }
        
        // 다운로드 주소로 이미지 생성
        // (모든 사진을 로드한 후 한번에 보여줌)
        for url in imgUrls {
            loadImageData(url: url) { data in
                self.loadCount += 1
                if let data = data { self.imgDatas.append(data) }
                
                // 모든 사진 로드 완료
                if self.loadCount == self.imgUrls.count {
                    _utils.removeIndicator()
                    guard self.imgDatas.count > 0 else {
                        let alert = _utils.createSimpleAlert(title: "사진", message: "사진정보가 없습니다.", buttonTitle: _strings[.ok]) { (_) in
                            self.dismiss(animated: true)
                        }
                        self.present(alert, animated: true)
                        return
                    }
                    self.setScrollview()
                    self.setExitButton()
                    self.createCells(imgDatas: self.imgDatas)
                }
            }
        }
    }
    
    // create thumb
    func createCells(imgDatas: [Data?]) {
        for (index, imgData) in imgDatas.enumerated() {
            let thumb = FullScreenImgThumb()
            thumb.delegate = self
            thumbs.append(thumb)
            stack.addArrangedSubview(thumb)
            thumb.configure(imgData: imgData, tag: index, selected: index == selectedImgIndex)
            thumb.widthAnchor.constraint(equalToConstant: stack.frame.height).isActive = true
        }
    }
    
    // load image
    private func loadImageData(url: String, completion: ((Data?) -> Void)? = nil) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: URL(string: url)!) {
                    completion?(data)
                } else {
                    completion?(nil)
                }
            }
        }
    }

    // scrollview
    private func setScrollview() {
        guard imgDatas.count > 0 else { return }
        
        // create scroll view
        imgSv = UIScrollView()
        imgSv.frame = CGRect(x: 0, y: 0, width: board.frame.width, height: board.frame.height)
        imgSv.backgroundColor = .black
        imgSv.isPagingEnabled = true
        imgSv.alwaysBounceVertical = false
        imgSv.showsHorizontalScrollIndicator = false
        imgSv.showsVerticalScrollIndicator = false
        imgSv.contentInsetAdjustmentBehavior = .never
        imgSv.delegate = self
        board.addSubview(imgSv)
        
        // set scroll view's content size
        var numberOfPage: Int = imgDatas.count
        if numberOfPage == 0 { numberOfPage = imgUrls.count }
        let contentWidth = board.frame.width * CGFloat(numberOfPage)
        imgSv.contentSize = CGSize(width: contentWidth, height: board.frame.height)
        
        // create scroll view page
        for i in 0 ..< numberOfPage {
            let page = createPage(index: i)
            imgSv.addSubview(page)
        }
    }
    
    // scroll view page
    private func createPage(index: Int) -> UIView {
        let boardFrame = board.frame
        let page = UIView(frame: CGRect(x: boardFrame.width * CGFloat(index), y: 0, width: boardFrame.width, height: boardFrame.height))
        page.backgroundColor = .clear
//        page.backgroundColor = UIColor(red: CGFloat.random(in: 0 ... 255)/255, green: CGFloat.random(in: 0 ... 255)/255, blue: CGFloat.random(in: 0 ... 255)/255, alpha: 1)
        page.tag = index
        
        
        let imageview = UIImageView()
        imageview.tag = imgTag
        imageview.frame = CGRect(x: 0, y: 0, width: boardFrame.width, height: boardFrame.height)
        imageview.contentMode = .scaleAspectFit
        
        if let imgData = imgDatas[index] {
            imageview.image = UIImage(data: imgData)
        }
        
        page.addSubview(imageview)
        return page
    }
    
    // exit button
    private func setExitButton() {
        let buttonWidth: CGFloat = 40
        let spaceX: CGFloat = 20
        let spacey: CGFloat = 10
        let exitBtn = UIButton(frame: CGRect(x: self.view.frame.width - buttonWidth - spaceX, y: buttonWidth + spacey, width: buttonWidth, height: buttonWidth))
        exitBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        exitBtn.tintColor = UIColor.white
        exitBtn.addTarget(self, action: #selector(self.exit(_:)), for: .touchUpInside)
        self.view.addSubview(exitBtn)
    }
    
    // cell selected/diselected
    private func setCellSelected(selectedIndex: Int) {
        if selectedIndex > thumbs.count - 1 { return }
        
        let selectedThumb = thumbs[selectedIndex]
        for thumb in thumbs {
            let isSelected = (selectedThumb == thumb)
            thumb.setSelected(selected: isSelected)
            
            if isSelected {
                imgSv.setContentOffset(CGPoint(x: CGFloat(selectedIndex) * imgSv.frame.width, y: 0), animated: true)
            }
        }
    }
}

// MARK: - Actions
extension FullScreenImgWithThumbsVc {
    @objc func exit(_ sender: UIButton) {
        _utils.removeIndicator()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionView
extension FullScreenImgWithThumbsVc: FullScreenImgThumbDelegate {
    func thumbSelected(tag: Int) {
        setCellSelected(selectedIndex: tag)
    }
}

extension FullScreenImgWithThumbsVc: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
        setCellSelected(selectedIndex: index)
        thumbsSv.setContentOffset(CGPoint(x: CGFloat(index) * (stack.frame.height + stack.spacing), y: 0), animated: true)
    }
}
