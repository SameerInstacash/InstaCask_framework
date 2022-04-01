//
//  DiagnosticTestResultVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import FirebaseDatabase
import PopupDialog
import BiometricAuthentication
import LocalAuthentication
import JGProgressHUD
import Alamofire
import SwiftyJSON

class ModelCompleteDiagnosticFlow: NSObject {
    var priority = 0
    var strTestType = ""
    var strSuccess = ""
}

class DiagnosticTestResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var testResultTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableViewTests: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var arrFailedAndSkipedTest = [ModelCompleteDiagnosticFlow]()
    var arrFunctionalTest = [ModelCompleteDiagnosticFlow]()
    var section = [""]
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUIElementsProperties()
        }
        
        AppOrientationUtility.lockOrientation(.portrait)
        
        self.tableViewTests.register(UINib(nibName: "TestResultCell", bundle: nil), forCellReuseIdentifier: "testResultCell")
        self.tableViewTests.register(UINib(nibName: "TestResultTitleCell", bundle: nil), forCellReuseIdentifier: "TestResultTitleCell")
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.createTableFromPassFailedTests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: AppThemeColor)
        
        self.tableViewTests.layer.cornerRadius = AppBtnCornerRadius
        
        self.btnContinue.backgroundColor = AppThemeColor
        self.btnContinue.layer.cornerRadius = AppBtnCornerRadius
        self.btnContinue.setTitleColor(AppBtnTitleColor, for: .normal)
        let fontSizeStart = self.btnContinue.titleLabel?.font.pointSize
        self.btnContinue.titleLabel?.font = UIFont.init(name: AppRobotoFontMedium, size: fontSizeStart ?? 18.0)
        
        // MultiLingual
        self.titleLbl.text = self.getLocalizatioStringValue(key: "TEST RESULT SUMMARY")
        self.btnContinue.setTitle(self.getLocalizatioStringValue(key: "Continue").uppercased(), for: .normal)
    }
    
    func createTableFromPassFailedTests() {
        
        self.arrFailedAndSkipedTest.removeAll()
        self.arrFunctionalTest.removeAll()
        
        if let val = AppUserDefaults.value(forKey: "deadPixel") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Dead Pixels"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "screen") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Screen"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
       
        if let val = AppUserDefaults.value(forKey: "Rotation") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Rotation"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Proximity") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Proximity"
            
            if val {
                
                if AppResultJSON["proximity"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Hardware Buttons") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Hardware Buttons"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        /*
        if let val = AppUserDefaults.value(forKey: "Earphone") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Earphone"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "USB") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Charger"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        */
        
        if let val = AppUserDefaults.value(forKey: "Camera") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Camera"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Autofocus") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Autofocus"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        var biometricTestName = ""
        if BioMetricAuthenticator.canAuthenticate() {
            
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                biometricTestName = "Face-Id Scanner"
            }else {
                biometricTestName = "Fingerprint Scanner"
            }
            
            if let val = AppUserDefaults.value(forKey: "Fingerprint Scanner") as? Bool {
                let model = ModelCompleteDiagnosticFlow()
                model.strTestType = biometricTestName
                
                if val {
                    self.arrFunctionalTest.append(model)
                }else {
                    self.arrFailedAndSkipedTest.append(model)
                }
            }
           
        }else {
            
            if LocalAuth.shared.hasTouchId() {
                print("Has Touch Id")
            } else if LocalAuth.shared.hasFaceId() {
                print("Has Face Id")
            } else {
                print("Device does not have Biometric Authentication Method")
            }
            
            print("Device does not have Biometric Authentication Method")
            
            biometricTestName = "Biometric Authentication"
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = biometricTestName
            self.arrFailedAndSkipedTest.append(model)
            
        }
        
        
        if let val = AppUserDefaults.value(forKey: "WIFI") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "WIFI"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Bluetooth") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Bluetooth"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "GSM") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "GSM"
            
            if val {
                
                if AppResultJSON["GSM"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "GSM") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "SMS Verification"
            
            if val {
                
                if AppResultJSON["GSM"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "GPS") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "GPS"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Microphone") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Microphone"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
             
        if let val = AppUserDefaults.value(forKey: "Speakers") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Speakers"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Vibrator") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Vibrator"
            
            if val {
                
                if AppResultJSON["Vibrator"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        /*
        if let val = AppUserDefaults.value(forKey: "Torch") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "FlashLight"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        */
        
        if let val = AppUserDefaults.value(forKey: "Storage") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Storage"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = AppUserDefaults.value(forKey: "Battery") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Battery"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
    
        
        if self.arrFailedAndSkipedTest.count > 0 {
            self.section = ["Failed and Skipped Tests", "Functional Checks"]
        }
        else{
            self.section = ["Functional Checks"]
        }
               
        self.tableViewTests.dataSource = self
        self.tableViewTests.delegate = self
        self.tableViewTests.reloadData()
                
    }
    
    
    // MARK: IBActions
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
                
        if reachability?.connection.description != "No Connection" {
            
            self.getProductsDetailsCosmetics()
            
        }else {
            self.showaAlert(message: self.getLocalizatioStringValue(key: "Please Check Internet connection."))
        }
                
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
    
    //MARK:- Tableview Delegates Methods
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if arrFailedAndSkipedTest.count > 0 {
                return  arrFailedAndSkipedTest.count + 1
            }
            else {
                return arrFunctionalTest.count + 1
            }
        }
        else {
           return arrFunctionalTest.count + 1
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrFailedAndSkipedTest.count > 0 {
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Failed and Skipped Tests")
                    cellfailed.lblSeperator.isHidden = true
                    
                    return cellfailed
                }else {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    //cellfailed.imgReTry.image = UIImage(named: "unverified")
                    //cellfailed.lblName.text = arrFailedAndSkipedTest[indexPath.row - 1].strTestType
                    cellfailed.lblName.text = self.getLocalizatioStringValue(key: arrFailedAndSkipedTest[indexPath.row - 1].strTestType)
                    
                    cellfailed.imgReTry.isHidden = true
                    cellfailed.lblReTry.isHidden = false
                    cellfailed.lblReTry.text = self.getLocalizatioStringValue(key: "ReTry")
                    cellfailed.lblSeperator.isHidden = false
                    
                    DispatchQueue.main.async {
                        
                        cellfailed.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                        cellfailed.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                        
                        if indexPath.row == 1 {
                            cellfailed.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFailedAndSkipedTest.count {
                            cellfailed.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                    
                            cellfailed.lblSeperator.isHidden = true
                        }
                    }
                                
                    return cellfailed
                }
                
            }
            else{
                
                if indexPath.row == 0 {
                    
                    let cellFunction = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellFunction.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                    cellFunction.lblSeperator.isHidden = true
                    
                    return cellFunction
                }else {
                    
                    let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                    cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                    cellFunction.imgReTry.isHidden = false
                    cellFunction.lblReTry.isHidden = true
                    cellFunction.lblSeperator.isHidden = false
                    
                    DispatchQueue.main.async {
                        cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                        cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                        
                        if indexPath.row == 1 {
                            cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFunctionalTest.count {
                            cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                            
                            cellFunction.lblSeperator.isHidden = true
                        }
                    }
               
                    return cellFunction
                }
                
            }
        }
        else{
            
            if indexPath.row == 0 {
                
                let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                cellfailed.lblSeperator.isHidden = true
                
                return cellfailed
            }else {
                
                let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                cellFunction.imgReTry.isHidden = false
                cellFunction.lblReTry.isHidden = true
                cellFunction.lblSeperator.isHidden = false
                
                    
                DispatchQueue.main.async {
                    cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                    cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                    
                    if indexPath.row == 1 {
                        cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                    }
                    
                    if indexPath.row == self.arrFunctionalTest.count {
                        cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                
                        cellFunction.lblSeperator.isHidden = true
                    }
                }
                                
                return cellFunction
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrFailedAndSkipedTest.count > 0 {
            if indexPath.section == 0 {
                if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Screen" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.screenRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Dead Pixels" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.deadPixelRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Rotation" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.rotationRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Proximity" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.proximityRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Hardware Buttons" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.volumeRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Earphone" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.earphoneRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Charger" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.chargerRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Camera" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.cameraRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Face-Id Scanner" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Fingerprint Scanner" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Biometric Authentication" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.biometricRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Bluetooth" ||  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GPS" ||  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GSM" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "SMS Verification" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "NFC" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Battery" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Storage" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "BackgroundTestsVC") as! BackgroundTestsVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.backgroundRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "WIFI" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.wifiRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Microphone" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.micRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Speakers" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.speakerRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Vibrator" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.vibratorRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Torch" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.flashLightRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Autofocus" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    vc.cameraRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                
                
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

open class LocalAuth: NSObject {

    public static let shared = LocalAuth()

    private override init() {}

    var laContext = LAContext()

    func canAuthenticate() -> Bool {
        var error: NSError?
        let hasTouchId = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return hasTouchId
    }

    func hasTouchId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .touchID {
            return true
        }
        return false
    }

    func hasFaceId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .faceID {
            return true
        }
        return false
    }

}
