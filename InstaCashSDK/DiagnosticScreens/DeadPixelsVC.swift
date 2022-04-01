//
//  DeadPixelsVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog

class DeadPixelsVC: UIViewController {

    var deadPixelRetryDiagnosis: (() -> Void)?
    var deadPixelTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    @IBOutlet weak var pixelView: UIView!
    
    var testPixelView = UIView()
    
    var isComingFromDiagnosticTestResult = false
    var pixelTimer: Timer?
    var pixelTimerIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
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
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.testPixelView.frame = screenSize
        self.testPixelView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(self.testPixelView)
     
        //self.pixelView.isHidden = !self.pixelView.isHidden
        
        self.pixelTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.setRandomBackgroundColor), userInfo: nil, repeats: true)
        
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
        
    // MARK: Custom Methods
    
    func setUIElementsProperties() {
        
        self.subHeadingLbl.setLineHeight(lineHeight: 3.0)
        self.subHeadingLbl.textAlignment = .center
        
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
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Dead Pixels")
        //self.titleLbl.text = self.getLocalizatioStringValue(key: "TECHCHECK® DIAGNOSTICS")
        self.titleLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Dead Pixel Test")
        self.headingLbl.font = UIFont.init(name: AppRobotoFontBold, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "We will show you multiple coloured screen with maximum brightness for 8-10 seconds. Please tell us if you see a black dot click “START” to begin")
        self.subHeadingLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.subHeadingLbl.font.pointSize)
      
    }
    
    @objc func setRandomBackgroundColor() {
        pixelTimerIndex += 1
        
        let colors = [
            #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.003921568627, blue: 0.9843137255, alpha: 1),#colorLiteral(red: 0.003921568627, green: 0.003921568627, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 0.9960784314, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 1, blue: 0.003921568627, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ]
        
        switch pixelTimerIndex {
        
        case 5:
                        
            self.testPixelView.removeFromSuperview()
            //self.pixelView.isHidden = !self.pixelView.isHidden
            
            //self.view.backgroundColor = colors[pixelTimerIndex]
            pixelTimer?.invalidate()
            pixelTimer = nil
            
            // Prepare the popup assets
            let title = self.getLocalizatioStringValue(key: "Dead Pixel Test")
            let message = self.getLocalizatioStringValue(key: "Did you see any black or white spots on the screen?")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
                
                AppUserDefaults.setValue(false, forKey: "deadPixel")
                AppResultJSON["Dead Pixels"].int = 0
                
                if !AppResultString.contains("SPTS03;") {
                    AppResultString = AppResultString + "SPTS03;"
                }
                
                if self.isComingFromDiagnosticTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
                
                AppUserDefaults.setValue(true, forKey: "deadPixel")
                AppResultJSON["Dead Pixels"].int = 1
                
                if AppResultString.contains("SPTS03;") {
                    AppResultString = AppResultString.replacingOccurrences(of: "SPTS03;", with: "")
                }
                
                if self.isComingFromDiagnosticTestResult {
                    
                    guard let didFinishRetryDiagnosis = self.deadPixelRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    guard let didFinishTestDiagnosis = self.deadPixelTestDiagnosis else { return }
                    didFinishTestDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            let buttonThree = DefaultButton(title: self.getLocalizatioStringValue(key: "Retry")) {
                self.pixelTimerIndex = 0
                self.startButtonPressed(UIButton())
            }
            
            
            // Add buttons to dialog
            // Alternatively, you can use popup.addButton(buttonOne)
            // to add a single button
            popup.addButtons([buttonOne, buttonTwo, buttonThree])
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
            
            break
            
        default:
            //self.view.backgroundColor = colors[pixelTimerIndex]
            
            //self.pixelView.backgroundColor = colors[pixelTimerIndex]
            self.testPixelView.backgroundColor = colors[pixelTimerIndex]
        }
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
