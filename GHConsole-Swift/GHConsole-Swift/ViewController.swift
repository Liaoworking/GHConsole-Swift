//
//  ViewController.swift
//  GHConsole-Swift
//
//  Created by Guanghui Liao on 1/22/18.
//  Copyright © 2018 liaoworking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        GGLog("This is a log I just want to show in GHConsole")
        
        let parameterDict = ["paraKey1":"paraValue1","paraKey2":"paraValue2","paraKey3":"paraValue3"] as [String:Any]
        GGLog("\(parameterDict)")
        
        //if you  want to see the responsJSon from the API, you can just use GGLog( ) like NSLog( ) here.
        GGLog("if you  want to see the responsJSon from the API, you can just use GGLog( ) like NSLog( ) here!")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

