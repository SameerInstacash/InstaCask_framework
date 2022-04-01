//
//  WiFiVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import Luminous
import JGProgressHUD

class WiFiVC: UIViewController {

    var wifiRetryDiagnosis: (() -> Void)?
    var wifiTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    var isComingFromDiagnosticTestResult = false
    let hud = JGProgressHUD()
    var wifiTimer: Timer?
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUIElementsProperties()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.subHeadingLbl.setLineHeight(lineHeight: 3.0)
        self.subHeadingLbl.textAlignment = .center
        
        self.setStatusBarColor(themeColor: AppThemeColor)
        
        self.startBtn.backgroundColor = AppThemeColor
        self.startBtn.layer.cornerRadius = AppBtnCornerRadius
        self.startBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let fontSizeStart = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: fontSizeStart ?? 18.0)
        
        self.skipBtn.backgroundColor = AppThemeColor
        self.skipBtn.layer.cornerRadius = AppBtnCornerRadius
        self.skipBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let fontSizeSkip = self.skipBtn.titleLabel?.font.pointSize
        self.skipBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: fontSizeSkip ?? 18.0)
        
        self.countLbl.textColor = AppThemeColor
        self.countLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = AppThemeColor
    
       
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Wifi")
        //self.titleLbl.text = self.getLocalizatioStringValue(key: "TECHCHECK® DIAGNOSTICS")
        self.titleLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking WiFi")
        self.headingLbl.font = UIFont.init(name: AppRobotoFontBold, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "To test WIFI, turn WIFI on and connect to your preferred network then Press “START“")
        self.subHeadingLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.subHeadingLbl.font.pointSize)
        
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start").uppercased()  {
                        
            self.wifiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            
        }else {
            self.skipButtonPressed(sender)
        }
        
    }
    
    @objc func runTimedCode() {
        
        self.count += 1
      
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking WiFi") + "..."
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.indicatorView = JGProgressHUDRingIndicatorView()
        self.hud.progress = Float(self.count)*0.25
        self.hud.show(in: self.view)
        
        if Luminous.Network.isConnectedViaWiFi {
            
            AppUserDefaults.setValue(true, forKey: "WIFI")
            AppResultJSON["WIFI"].int = 1
            
            if AppResultString.contains("CISS04;") {
                AppResultString = AppResultString.replacingOccurrences(of: "CISS04;", with: "")
            }
            
        }else {
            
            AppUserDefaults.setValue(false, forKey: "WIFI")
            AppResultJSON["WIFI"].int = 0
            
            if !AppResultString.contains("CISS04;") {
                AppResultString = AppResultString + "CISS04;"
            }
            
        }
        
        if count == 4 {
            //DispatchQueue.main.async {
                
                self.hud.dismiss()
                
                self.wifiTimer?.invalidate()
                self.wifiTimer = nil
                
                if self.isComingFromDiagnosticTestResult {
                    
                    print("FaTa1")
                    guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    print("FaTa2")
                    guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
                    didFinishTestDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
            //}
            
        }
        
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        // Prepare the popup assets
        
        let title = self.getLocalizatioStringValue(key: "WiFi Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")    ) {
            
            AppResultJSON["WIFI"].int = -1
            AppUserDefaults.setValue(false, forKey: "WIFI")
            
            if !AppResultString.contains("CISS04") {
                AppResultString = AppResultString + "CISS04;"
            }

            if self.isComingFromDiagnosticTestResult {
                
                guard let didFinishRetryDiagnosis = self.wifiRetryDiagnosis else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                
                guard let didFinishTestDiagnosis = self.wifiTestDiagnosis else { return }
                didFinishTestDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
        
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No").uppercased()) {
            //Do Nothing
            self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
            
            popup.dismiss(animated: true, completion: nil)
        }
        
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: AppRobotoFontBold, size: 26)!
            pv.messageFont  = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            pv.titleFont    = UIFont(name: AppRobotoFontBold, size: 20)!
            pv.messageFont  = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        DispatchQueue.main.async {
            db.titleLabel?.textColor = AppThemeColor
        }
        if UIDevice.current.model.hasPrefix("iPad") {
            db.titleFont      = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            db.titleFont      = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
                
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            cb.titleFont      = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            cb.titleFont      = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }

    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key:"Quit Diagnosis")
        let message = self.getLocalizatioStringValue(key:"Are you sure you want to quit?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")    ) {
            DispatchQueue.main.async() {
                //self.dismiss(animated: true) {
                    self.NavigateToHomePage()
                //}
            }
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")    ) {
            //Do Nothing
            popup.dismiss(animated: true, completion: nil)
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: AppRobotoFontBold, size: 26)!
            pv.messageFont  = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            pv.titleFont    = UIFont(name: AppRobotoFontBold, size: 20)!
            pv.messageFont  = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        DispatchQueue.main.async {
            db.titleLabel?.textColor = AppThemeColor
        }
        if UIDevice.current.model.hasPrefix("iPad") {
            db.titleFont      = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            db.titleFont      = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
                
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            cb.titleFont      = UIFont(name: AppRobotoFontRegular, size: 22)!
        }else {
            cb.titleFont      = UIFont(name: AppRobotoFontRegular, size: 16)!
        }
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
