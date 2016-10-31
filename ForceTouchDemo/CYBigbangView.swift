//
//  CYBigbangView.swift
//  ForceTouchDemo
//
//  Created by chaoyang805 on 16/10/30.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

import UIKit
import RxSwift
import MobileCoreServices
class CYBigbangView: UITextView {
    
    private var disposeBag = DisposeBag()
    private lazy var  btnColor: UIColor = {
        return UIColor(red: 0, green: 122 / 255, blue: 1.0, alpha: 1.0)
    }()
    
    let feedback = UIImpactFeedbackGenerator(style: .heavy)
    var bigbangFired = false
    
    var hSpacing: CGFloat = 10
    var vSpacing: CGFloat = 10
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.clipsToBounds = false

    }
    
    private func presentActionSheet(with text: String) {
        
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "复制", style: .default, handler: { action in
            NSLog("share \(text)")
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = text
        })
        alert.addAction(shareAction)
        let copyAction = UIAlertAction(title: "分享", style: .default, handler: { action in
            NSLog("copy \(text)")
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            self.findNearestViewController()?.present(activityVC, animated: true, completion: nil)
            
        })
        
        alert.addAction(copyAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if let vc = self.findNearestViewController() {
            vc.present(alert, animated: true, completion: nil)
        } else {
            NSLog("failed to find vc")
        }
    }
    
    lazy var presentBigbang: ([String]) -> Void = {
        
        return { words in
            
            NSLog("presenting:\(words)")
            let containerWidth = UIScreen.main.bounds.width * 0.8
            let containerHeight = UIScreen.main.bounds.height * 0.8
            let container = UIScrollView()
            container.tag = 0x1010
            container.backgroundColor = UIColor.darkGray
            container.layer.cornerRadius = 4
            var currentXPos = self.hSpacing
            var currentYPos = self.vSpacing
            var maxYPos = self.vSpacing
            
            var btnXPos = currentXPos
            var btnYPos = currentYPos
            var currentBtn: UIButton?
            var tapEvent:(_ text: String) -> (() -> Void) = { text in
                return {
                    NSLog("button \(text) tapped")
                
                }
            }
            for word in words {
                
                currentBtn = UIButton(type: .system)
                currentBtn!.setTitle(word, for: .normal)
                currentBtn!.sizeToFit()
                currentBtn!.setTitleColor(UIColor.white, for: .normal)
                
                currentBtn!.rx
                    .tap
                    .map { word }
                    .subscribe (onNext: self.presentActionSheet)
                    .addDisposableTo(self.disposeBag)
                // 如果再添加一个 button 后宽度超出了父 View 的宽度，向下折行
                if currentXPos + currentBtn!.bounds.width + self.hSpacing > containerWidth {
                    currentXPos = self.hSpacing
                    currentYPos += self.vSpacing + currentBtn!.bounds.height
                    maxYPos = currentYPos
                }
                currentBtn!.frame.origin = CGPoint(x: currentXPos, y: currentYPos)
                container.addSubview(currentBtn!)
                currentXPos += currentBtn!.bounds.width + self.hSpacing
                
            }
            
            if currentBtn != nil {
                maxYPos += currentBtn!.bounds.height + self.vSpacing
            }
            
            let dismissBtn = UIButton(type: .system)
            dismissBtn.setTitle("关闭", for: .normal)
            dismissBtn.frame = CGRect(x: 0, y: maxYPos, width: containerWidth, height: 44)
            dismissBtn.rx
                .tap
                .subscribe(onNext: { () in
                    container.removeFromSuperview()
                })
                .addDisposableTo(self.disposeBag)
            container.addSubview(dismissBtn)
            
            maxYPos += 54
            
            let containerX: CGFloat = 30
            let containerY: CGFloat = 60
            var containerOrigin = CGPoint(x: 30, y: 60)
            if self.superview != nil {
                containerOrigin = self.convert(containerOrigin, from: self.superview!)
            }
            
            container.frame = CGRect(origin: containerOrigin, size: CGSize(width: containerWidth, height: containerHeight))
            container.isScrollEnabled = true
            container.contentSize = CGSize(width: containerWidth, height: maxYPos)
            container.alpha = 0
            container.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.addSubview(container)
            
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.7,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: { 
                    container.alpha = 1
                    container.transform = CGAffineTransform.identity
                },
                completion: nil)
        }
    
    }()
    
    lazy var fireBigbang: (UITouch) -> Void = {
        return { touch in
            
            NSLog("force touch")
            self.bigbangFired = true
            self.feedback.impactOccurred()
            
        }
    }()
    
    lazy var mapAndFilter: (String) -> [String] = {
    
        return {
            
            let regex = try! NSRegularExpression(pattern: "[\\u3002\\uff1b\\uff0c\\uff1a\\u201c\\u201d\\uff08\\uff09\\u3001\\uff1f\\u300a\\u300b\\uff01]", options: .allowCommentsAndWhitespace)
                
            return $0.components(separatedBy: CharacterSet.whitespaces)
                .filter {
                !(regex.matches(in: $0, options: [], range: NSRange(location: 0, length: $0.characters.count)).count > 0)
            }
        }
    
    }()
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let container = viewWithTag(0x1010) as? UIScrollView {
            let p = container.convert(point, from: self)
            if container.bounds.contains(p) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        feedback.prepare()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !bigbangFired else {
            super.touchesBegan(touches, with: event)
            return
        }
        
        guard let text = self.text, !text.isEmpty else {
            NSLog("text is empty")
            return
        }
        
        let disposable = Observable
            .just(touch)
            .filter {
                $0.force > 4.0 && $0.force < 6.0
            }
            .do(onNext: self.fireBigbang)
            .subscribeOn(MainScheduler.instance)
            .flatMap { (touch) -> Observable<String> in
                return XFWordSpliter.splitText(text)
            }
            .map(self.mapAndFilter)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
            .observeOn(MainScheduler.instance)
            .subscribe(
                
                onNext: self.presentBigbang,
                onError: { NSLog("error: \($0)")},
                onCompleted: nil,
                onDisposed: nil)
        
        disposeBag.insert(disposable)
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bigbangFired = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bigbangFired = false
    }
    
}
