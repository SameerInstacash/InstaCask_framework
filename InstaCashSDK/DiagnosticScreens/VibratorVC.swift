//
//  VibratorVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import CoreMotion
import AVKit

class VibratorVC: UIViewController {

    var vibratorRetryDiagnosis: (() -> Void)?
    var vibratorTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var numberTxtField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    var isComingFromDiagnosticTestResult = false
    var num1 = 0
    var gameTimer: Timer?
    var runCount = 0

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
        
        self.hideKeyboardWhenTappedAroundView()
        self.setStatusBarColor(themeColor: AppThemeColor)
        
        self.startBtn.backgroundColor = AppThemeColor
        self.startBtn.layer.cornerRadius = AppBtnCornerRadius
        self.startBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let fontSize = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: fontSize ?? 18.0)
        
        self.skipBtn.backgroundColor = AppThemeColor
        self.skipBtn.layer.cornerRadius = AppBtnCornerRadius
        self.skipBtn.setTitleColor(AppBtnTitleColor, for: .normal)
        let skipFontSize = self.skipBtn.titleLabel?.font.pointSize
        self.skipBtn.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: skipFontSize ?? 18.0)
        
        self.countLbl.textColor = AppThemeColor
        self.countLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = AppThemeColor
    
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Vibrator")
        //self.titleLbl.text = self.getLocalizatioStringValue(key: "TECHCHECK® DIAGNOSTICS")
        self.titleLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Vibrator")
        self.headingLbl.font = UIFont.init(name: AppRobotoFontBold, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Count how many times your phone has vibrated and then type it in the text box provided")
        self.subHeadingLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.subHeadingLbl.font.pointSize)
        self.numberTxtField.placeholder = self.getLocalizatioStringValue(key: "Type Number")
        self.numberTxtField.font = UIFont.init(name: AppRobotoFontRegular, size: self.numberTxtField.font?.pointSize ?? 16.0)
       
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start").uppercased() {
            sender.setTitle(self.getLocalizatioStringValue(key: "Submit").uppercased(), for: .normal)
            
            self.startTest()
        }else {
            
            guard !(self.numberTxtField.text?.isEmpty ?? false) else {
                self.showaAlert(message: self.getLocalizatioStringValue(key: "Enter Number"))
                return
            }
            
            if self.numberTxtField.text == String(num1) {

                AppResultJSON["Vibrator"].int = 1
                AppUserDefaults.setValue(true, forKey: "Vibrator")
                
                if AppResultString.contains("CISS13;") {
                    AppResultString = AppResultString.replacingOccurrences(of: "CISS13;", with: "")
                }
                
                self.goNext()
            }else {

                AppResultJSON["Vibrator"].int = 0
                AppUserDefaults.setValue(false, forKey: "Vibrator")
                
                if !AppResultString.contains("CISS13;") {
                    AppResultString = AppResultString + "CISS13;"
                }
                
                self.goNext()
            }
            
        }
    
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        let randomNumber = Int.random(in: 1...5)
        print("Number: \(randomNumber)")
        self.num1 = randomNumber
        
        self.gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        
        runCount += 1
        self.checkVibrator()
        
        if runCount == self.num1 {
            gameTimer?.invalidate()
            self.numberTxtField.isHidden = false
        }
        
    }
    
    func checkVibrator() {
        
        let manager = CMMotionManager()
        if manager.isDeviceMotionAvailable {
            
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data: CMDeviceMotion?, error: Error?) in
               
                if let x = data?.userAcceleration.x, x > 0.03 {
                    print("Device Vibrated at: \(x)")
                    manager.stopDeviceMotionUpdates()
                }
            }
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
        }else {
            
            self.showAlert(title: self.getLocalizatioStringValue(key: "Error"), message: self.getLocalizatioStringValue(key: "Vibrator not working"), alertButtonTitles: [self.getLocalizatioStringValue(key: "OK")], alertButtonStyles: [.default], vc: self) { (index) in
                
                AppResultJSON["Vibrator"].int = 0
                AppUserDefaults.setValue(false, forKey: "Vibrator")
                
                if !AppResultString.contains("CISS13;") {
                    AppResultString = AppResultString + "CISS13;"
                }
                
                self.goNext()
                
            }
            
        }
        
    }
    
    func goNext() {
        
        if self.isComingFromDiagnosticTestResult {
                        
            guard let didFinishRetryDiagnosis = self.vibratorRetryDiagnosis else { return }
            didFinishRetryDiagnosis()
            self.dismiss(animated: false, completion: nil)
        }
        else{
                        
            guard let didFinishTestDiagnosis = self.vibratorTestDiagnosis else { return }
            didFinishTestDiagnosis()
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func skipTest() {
        
        // Prepare the popup assets
        
        let title = self.getLocalizatioStringValue(key: "Vibrator Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered. Do you still want to skip?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")) {
            
            AppResultJSON["Vibrator"].int = -1
            AppUserDefaults.setValue(false, forKey: "Vibrator")
            
            if !AppResultString.contains("CISS13;") {
                AppResultString = AppResultString + "CISS13;"
            }
                
            self.goNext()
          
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No").uppercased()) {
            //Do Nothing
            self.startBtn.setTitle(self.getLocalizatioStringValue(key:"Start").uppercased(), for: .normal)
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
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")) {
            DispatchQueue.main.async() {
                //self.dismiss(animated: true) {
                    self.NavigateToHomePage()
                //}
            }
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")) {
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
