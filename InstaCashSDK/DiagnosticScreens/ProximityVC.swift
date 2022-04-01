//
//  ProximityVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog

class ProximityVC: UIViewController {

    var proximityRetryDiagnosis: (() -> Void)?
    var proximityTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    @IBOutlet weak var viewGuide: UIView!
    @IBOutlet weak var proximityImageView: UIImageView!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var startGuideBtn: UIButton!
    
    var isComingFromDiagnosticTestResult = false
    var hasStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUIElementsProperties()
        }
        
        
        if UIDevice.current.model.hasPrefix("iPad") {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkDeviceSupportForProximity()
            }
            
        }else {
            self.checkDeviceSupportForProximity()
        }
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: AppThemeColor)
        
        self.startBtn.backgroundColor = AppThemeColor
        self.startBtn.layer.cornerRadius = AppBtnCornerRadius
        self.startBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let fontSize = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: fontSize ?? 18.0)
        
        self.countLbl.textColor = AppThemeColor
        self.countLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = AppThemeColor
    
       
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Proximity")
        //self.titleLbl.text = self.getLocalizatioStringValue(key: "TECHCHECK® DIAGNOSTICS")
        self.titleLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Proximity Sensor")
        self.headingLbl.font = UIFont.init(name: AppRobotoFontBold, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Wave your hand infront of the screen")
        self.subHeadingLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.subHeadingLbl.font.pointSize)
        
        self.proximityImageView.loadGif(name: "proximity")
        
        self.guideBtn.setTitle(self.getLocalizatioStringValue(key: "Guide me").uppercased(), for: .normal)
        self.guideBtn.setTitleColor(AppThemeColor, for: .normal)
        let guideBtnFontSize = self.guideBtn.titleLabel?.font.pointSize
        self.guideBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontBold, size: guideBtnFontSize ?? 18.0)
        
        self.startGuideBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.startGuideBtn.backgroundColor = AppThemeColor
        self.startGuideBtn.layer.cornerRadius = AppBtnCornerRadius
        self.startGuideBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let startGuideBtnFontSize = self.startGuideBtn.titleLabel?.font.pointSize
        self.startGuideBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: startGuideBtnFontSize ?? 18.0)
        
    }
    
    func checkDeviceSupportForProximity() {
        
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        
        if !device.isProximityMonitoringEnabled {
            // Proximity not supported so go ahead
            
            DispatchQueue.main.async {
                
                AppUserDefaults.setValue(true, forKey: "Proximity")
                AppResultJSON["Proximity"].int = -2
                
                if self.isComingFromDiagnosticTestResult {
                                        
                    guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                                        
                    guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                    didFinishTestDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    // MARK:- IBActions
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if hasStarted {
            
            hasStarted = false
            self.btnSkipPerform()
            
        }else {
            
            hasStarted = true
            
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = true
            
            if device.isProximityMonitoringEnabled {
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: device)
                                
            }else {
                // Proximity not supported so go ahead
                
                AppUserDefaults.setValue(true, forKey: "Proximity")
                AppResultJSON["Proximity"].int = -2
                
                if self.isComingFromDiagnosticTestResult {
                                        
                    guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                                        
                    guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                    didFinishTestDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            self.startBtn.setTitle(self.getLocalizatioStringValue(key:"Skip").uppercased(), for: .normal)
        }
        
    }
    
    @objc func proximityChanged(notification: NSNotification) {
        
        if (notification.object as? UIDevice) != nil {
            
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = false
            
            AppUserDefaults.setValue(true, forKey: "Proximity")
            AppResultJSON["Proximity"].int = 1
            
            if AppResultString.contains("CISS15;") {
                AppResultString = AppResultString.replacingOccurrences(of: "CISS15;", with: "")
            }
            
            if self.isComingFromDiagnosticTestResult {
                                    
                guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                                    
                guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                didFinishTestDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            
        }
    }
    
    func btnSkipPerform() {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Skip Proximity Sensor")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?")
        
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")  ) {
            
            AppUserDefaults.setValue(false, forKey: "Proximity")
            AppResultJSON["Proximity"].int = -1
            
            if !AppResultString.contains("CISS15;") {
                AppResultString = AppResultString + "CISS15;"
            }
            
            if self.isComingFromDiagnosticTestResult {
                                    
                guard let didFinishRetryDiagnosis = self.proximityRetryDiagnosis else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                                    
                guard let didFinishTestDiagnosis = self.proximityTestDiagnosis else { return }
                didFinishTestDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
         
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")  ) {
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
    
    @IBAction func onClickGuide(_ sender: UIButton) {
        self.viewGuide.isHidden = false
    }
    
    @IBAction func onClickStart(_ sender: UIButton) {
        self.viewGuide.isHidden = true
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
    
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key:"Quit Diagnosis")
        let message = self.getLocalizatioStringValue(key:"Are you sure you want to quit?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")  ) {
            DispatchQueue.main.async() {
                //self.dismiss(animated: true) {
                    self.NavigateToHomePage()
                //}
            }
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")  ) {
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
