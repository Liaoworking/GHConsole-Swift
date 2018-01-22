//
//  GHConsole.swift
//  GHConsole-Swift
//
//  Created by Guanghui Liao on 1/21/18.
//  Copyright © 2018 liaoworking. All rights reserved.
//

import UIKit
//MARK: - GHConsoleRootViewController
class GHConsoleRootViewController: UIViewController {
    
    lazy var textView = UITextView()
    var text: String = ""{
        didSet{
                textView.text = text
                textView.scrollRectToVisible(CGRect(x: 0.0, y: textView.contentSize.height-15, width: textView.contentSize.width, height: 10), animated: true)
        }
    }
    var isScrllEnable:Bool = false{
        didSet{
                textView.isScrollEnabled = isScrllEnable
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextView()
    }
    
    func configTextView() {
        textView.frame = self.view.bounds
        textView.backgroundColor = UIColor.black
        //mark- TODO
        textView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue|UIViewAutoresizing.flexibleHeight.rawValue)
        textView.font = UIFont.boldSystemFont(ofSize: 13)
        textView.textColor = UIColor.white
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.alwaysBounceVertical = true
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(textView)
        textView.text = self.text as String!
        textView.scrollRectToVisible(CGRect(x: 0.0, y: textView.contentSize.height-15, width: textView.contentSize.width, height: 10), animated: true)
    }

}

//MARK: - GHConsoleWindow
class GHConsoleWindow: UIWindow {
    var consoleRootViewController: GHConsoleRootViewController?{
        get{
            return self.rootViewController as? GHConsoleRootViewController
        }
    }
    
    class func consoleWindow() -> GHConsoleWindow {
        let window = self.init()
        window.windowLevel = UIWindowLevelStatusBar + 100
        window.frame = CGRect(x: UIScreen.main.bounds.size.width - 30, y: 120, width: 30, height: 90)
        window.rootViewController = GHConsoleRootViewController()
        window.backgroundColor = UIColor.purple
        return window
    }

    func maxmize() {
        frame = UIScreen.main.bounds
        consoleRootViewController?.isScrllEnable = true
    }

    func minimize() {
        frame = CGRect(x: UIScreen.main.bounds.size.width - 30, y: 120, width: 30, height: 90)
        consoleRootViewController?.isScrllEnable = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.rootViewController?.view.frame = self.bounds
    }
}

//MARK: -GHConsole
public class GHConsole: NSObject {

    var timeString:String = ""
    var isShowConsole = false
    var logString:String = ""
    var currentLogCount:Int = 0
    var isFullScreen = false
    var panOutGesture: UIPanGestureRecognizer?
    var consoleWindow = GHConsoleWindow.consoleWindow()
    var formatter = DateFormatter()
    var msgString = ""
    var now:Date{
        get{
            return Date()
        }
    }
    
   public static let sharedConsole = GHConsole() //单例
    
    private override init() {
        self.logString = ""
        super.init()
    }
    
    func startPrintLog() {
        configConsoleWindow()
        consoleWindow.isHidden = false
        isShowConsole = false
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        consoleWindow.minimize()
    }
    
    func stopPrinting() {
        consoleWindow.isHidden = true
        isShowConsole = false
    }
    
    func configConsoleWindow() {
        consoleWindow.rootViewController = GHConsoleRootViewController()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapTextView(tap:)))
        tapGesture.numberOfTapsRequired = 2
        panOutGesture = UIPanGestureRecognizer(target: self, action: #selector(panOutTextView(panGesture:)))
        consoleWindow.rootViewController?.view.addGestureRecognizer(tapGesture)
        consoleWindow.rootViewController?.view.addGestureRecognizer(panOutGesture!)
    }
    
    func printing(function:StaticString, line:UInt, msg:String) {
        msgString = "\(formatter.string(from: now)) \(String(describing: function))  \(String(describing: line)+"-"+msg)\n\n"
        print(msgString)
        logString.append(msgString)
        
        if isShowConsole && isFullScreen {
            consoleWindow.consoleRootViewController?.text = logString
        }
    }
    
   @objc func doubleTapTextView(tap:UITapGestureRecognizer) {
    if !isFullScreen {//放大
        UIView.animate(withDuration: 0.2, animations: {
            DispatchQueue.main.async {
                self.consoleWindow.consoleRootViewController?.text = self.logString;
            }
            self.consoleWindow.maxmize()
        }, completion: { (yesOrNo) in
            self.isFullScreen = true
        })
    }else{//缩小
        UIView.animate(withDuration: 0.2, animations: {
            self.consoleWindow.minimize()
        }, completion: { (yesOrNo) in
            self.isFullScreen = false
        })
    }
    }
    
    @objc func panOutTextView(panGesture:UIPanGestureRecognizer) {
        if isFullScreen {
            return
        }else{
            if  panOutGesture?.state == .changed{
               let transPoint = panOutGesture?.translation(in: UIApplication.shared.keyWindow)
                var rect = consoleWindow.frame
                rect.origin.y += (transPoint?.y)!
                    if rect.origin.y < 0{
                       rect.origin.y = 0
                    }
                let maxY = UIScreen.main.bounds.size.height - rect.size.height
                    if rect.origin.y > maxY{
                    rect.origin.y = maxY
                    }
                consoleWindow.frame = rect
                panOutGesture?.setTranslation(CGPoint.zero, in: UIApplication.shared.keyWindow)
            }
        }
    }
}


public func GGLog(_ msg: @autoclosure () -> String, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, logger:GHConsole = GHConsole.sharedConsole) {
    logger.printing(function: function, line: line, msg: msg())
}
