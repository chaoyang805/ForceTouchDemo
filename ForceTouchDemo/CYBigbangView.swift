//
//  CYBigbangView.swift
//  ForceTouchDemo
//
//  Created by chaoyang805 on 16/10/30.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

import UIKit
import RxSwift

class CYBigbangView: UITextView {
    
    private var disposeBag = DisposeBag()
    
    var bigbangFired = false
    let feedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var hSpacing: CGFloat = 10
    var vSpacing: CGFloat = 10
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.clipsToBounds = false
    }
    
    lazy var presentBigbang: ([String]) -> Void = {
        
        return { words in
            
            NSLog("presenting:\(words)")
            let containerWidth = UIScreen.main.bounds.width * 0.8
            let container = UIScrollView()
            container.backgroundColor = UIColor.yellow
            var currentXPos = self.hSpacing
            var currentYPos = self.vSpacing
            var maxYPos = self.vSpacing
            
            var btnXPos = currentXPos
            var btnYPos = currentYPos
            var currentBtn: UIButton?
            
            for word in words {
                
                currentBtn = UIButton(type: .system)
                currentBtn!.setTitle(word, for: .normal)
                currentBtn!.sizeToFit()
                
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
            
            let containerX: CGFloat = 30
            let containerY: CGFloat = 60
            var containerOrigin = CGPoint(x: 30, y: 60)
            if self.superview != nil {
                containerOrigin = self.convert(containerOrigin, from: self.superview!)
            }
            container.frame = CGRect(origin: containerOrigin, size: CGSize(width: containerWidth, height: 200))
            container.isScrollEnabled = true
            container.contentSize = CGSize(width: containerWidth, height: maxYPos)
            
            self.addSubview(container)
        }
    
    }()
    
    lazy var fireBigbang: (UITouch) -> Void = {
        return { touch in
            
            NSLog("force touch")
            self.bigbangFired = true
            self.feedback.impactOccurred()
            
        }
    }()
    
    
//    lazy var fireBigbang: (UITouch) -> Void = {
//        
//        return { touch in
//            NSLog("force touch")
//            self.bigbangFired = true
//            
//            self.feedback.impactOccurred()
//            
//            XFWordSpliter.splitText(self.text)
//                .map { $0.components(separatedBy: CharacterSet.whitespaces) }
//                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
//            
    
            
//            self.processWordSplit(self.text)
//                .map { $0.components(separatedBy: CharacterSet.whitespaces) }
//                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
//                .observeOn(MainScheduler.instance)
//                .subscribe(
//                    onNext: self.presentBigbang,
//                    onError: nil,
//                    onCompleted: nil,
//                    onDisposed: nil)
//                .addDisposableTo(self.disposeBag)
//            
//        }
//    }()
//    
//    lazy var processWordSplit: (String) -> Observable<String> = {
//        NSLog("process word split")
//        return { text in
//            
//            return Observable.create { (observer: AnyObserver<Data>) -> Disposable in
//                
//                let parameters = "api_key=q114o7u7c8W2G0y2m5v0yLOZIVqCkpDmAKzTVIEs&text=神奇女侠盖尔霸气总攻不见不散&pattern=ws&format=plain"
//
//                guard let url = URL(string: "http://ltpapi.voicecloud.cn/analysis/?api_key=q114o7u7c8W2G0y2m5v0yLOZIVqCkpDmAKzTVIEs&text=%E5%93%88%E5%B7%A5%E5%A4%A7%E5%92%8C%E7%A7%91%E5%A4%A7%E8%AE%AF%E9%A3%9E%E8%81%94%E5%90%88%E7%A0%94%E5%8F%91%E7%9A%84%E4%BA%91%E7%AB%AF%E4%B8%AD%E6%96%87%E8%87%AA%E7%84%B6%E8%AF%AD%E8%A8%80%E5%A4%84%E7%90%86%E6%9C%8D%E5%8A%A1%E5%B9%B3%E5%8F%B0%EF%BC%8C%E6%8F%90%E4%BE%9B%E5%88%86%E8%AF%8D%E3%80%81%E8%AF%8D%E6%80%A7%E6%A0%87%E6%B3%A8%E3%80%81%E5%91%BD%E5%90%8D%E5%AE%9E%E4%BD%93%E8%AF%86%E5%88%AB%E3%80%81%E4%BE%9D%E5%AD%98%E5%8F%A5%E6%B3%95%E5%88%86%E6%9E%90%E3%80%81%E8%AF%AD%E4%B9%89%E8%A7%92%E8%89%B2%E6%A0%87%E6%B3%A8%E7%AD%89%E8%87%AA%E7%84%B6%E8%AF%AD%E8%A8%80%E5%A4%84%E7%90%86%E6%9C%8D%E5%8A%A1&pattern=ws&format=plain") else {
//                    NSLog("url invalid")
//                    return Disposables.create()
//                }
//                let request = URLRequest(url: url)
//                
//                URLSession.shared.dataTask(with: request) { (data, response, error) in
//                    NSLog("response:\(response)")
//                    if let _ = data {
//                        NSLog("on next")
//                        observer.onNext(data!)
//                    }
//                    if let e = error {
//                        NSLog("on error \(e)")
//                        observer.onError(e)
//                    }
//                    observer.onCompleted()
//                        
//                }.resume()
//                return Disposables.create()
//                
//            }
//            .map { String(data: $0, encoding: .utf8) }
//            .unwrap()
//        
//        }
//    
//    }()
    
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
                $0.force > 4.0 && $0.force < 5.0
            }
            .do(onNext: self.fireBigbang)
            .flatMap { (touch) -> Observable<String> in
                return XFWordSpliter.splitText(text)
            }
            .map { $0.components(separatedBy: CharacterSet.whitespaces) }
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
