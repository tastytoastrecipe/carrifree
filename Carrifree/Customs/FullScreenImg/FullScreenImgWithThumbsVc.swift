//
//  FullScreenImgWithThumbsVc.swift
//  TestProject
//
//  Created by plattics-kwon on 2022/01/20.
//
//
//  π¬ FullScreenImgWithThumbsVc
//  μ¬λ¬κ°μ μ΄λ―Έμ§λ€μ νμ₯μ© μ μ²΄νλ©΄μΌλ‘ νμ.
//  νλ¨μ μΈλ€μΌ λͺ©λ‘μ νμνκ³  μΈλ€μΌμ μ ννλ©΄
//  ν΄λΉμ΄λ―Έμ§κ° μ μ²΄νλ©΄μ νμλ¨.

import UIKit

class FullScreenImgWithThumbsVc: UIViewController {

    @IBOutlet weak var board: UIView!           // μ μ²΄νλ©΄μ νμλ  μ΄λ―Έμ§μ parent
    @IBOutlet weak var stack: UIStackView!      // μΈλ€μΌ μ΄λ―Έμ§λ€μ΄ νμλ  stack view
    @IBOutlet weak var thumbsSv: UIScrollView!  // μΈλ€μΌ μ΄λ―Έμ§λ€μ΄ νμλ  scroll view

    let imgTag: Int = 11
    var imgUrls: [String] = []      // νμλ  μ΄λ―Έμ§λ€μ url
    var imgDatas: [Data?] = []      // νμλ  μ΄λ―Έμ§λ€μ data
    var selectedImgIndex: Int = 0   // νμ¬ μ νλ μ΄λ―Έμ§μ μΈλ±μ€
    var loadCount: Int = 0          // νμ¬ λ‘λλ μ΄λ―Έμ§μ μ (urlλ‘ λΆλ¬μ¬λ)
    var imgSv: UIScrollView!        // μ μ²΄νλ©΄μ νμλ  μ΄λ―Έμ§λ₯Ό λ΄λ scroll view (νμ΄μ§ ν¨κ³Ό μ μ©)
    var thumbs: [FullScreenImgThumb] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.configure()
        }
    }
    
    func configure() {
        thumbsSv.decelerationRate = .fast
        
        // μ΄λ―Έμ§ λ°μ΄ν°λ‘ μ΄λ―Έμ§ μμ±
        if imgDatas.count > 0 {
            setScrollview()
            setExitButton()
            self.createCells(imgDatas: imgDatas)
            return
        }
        
        // show indicator
        if imgUrls.count > 0 { _ = _utils.createIndicator() }
        
        // λ€μ΄λ‘λ μ£Όμλ‘ μ΄λ―Έμ§ μμ±
        // (λͺ¨λ  μ¬μ§μ λ‘λν ν νλ²μ λ³΄μ¬μ€)
        for url in imgUrls {
            loadImageData(url: url) { data in
                self.loadCount += 1
                if let data = data { self.imgDatas.append(data) }
                
                // λͺ¨λ  μ¬μ§ λ‘λ μλ£
                if self.loadCount == self.imgUrls.count {
                    _utils.removeIndicator()
                    guard self.imgDatas.count > 0 else {
                        let alert = _utils.createSimpleAlert(title: "μ¬μ§", message: "μ¬μ§μ λ³΄κ° μμ΅λλ€.", buttonTitle: _strings[.ok]) { (_) in
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
