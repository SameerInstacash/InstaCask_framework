//
//  BackgroundTestsVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import PopupDialog
import Luminous
import SwiftyJSON
import CoreBluetooth
import JGProgressHUD
import CoreTelephony
import CoreLocation
import INTULocationManager

class BackgroundTestsVC: UIViewController, CBCentralManagerDelegate, CLLocationManagerDelegate {
    
    var backgroundRetryDiagnosis: (() -> Void)?
    var backgroundTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    var isComingFromDiagnosticTestResult = false
    
    let hud = JGProgressHUD()
    var isCapableToCall: Bool = false
    var blueToothManager: CBCentralManager!
    //var locationManager : CLLocationManager? = nil
    let locationManager = INTULocationManager.sharedInstance()
    var gpsTimer: Timer?
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLocationAccessEnabled()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUIElementsProperties()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
        
        self.blueToothManager = CBCentralManager()
        self.blueToothManager.delegate = self
        
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
          
        self.countLbl.textColor = AppThemeColor
        self.countLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = AppThemeColor
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        //self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "SMART DIAGNOSTICS")
        self.titleLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.titleLbl.font.pointSize)
        //self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking WiFi")
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Please make sure Bluetooth and GPS are enabled on your device and press begin to start the tests")
        self.subHeadingLbl.font = UIFont.init(name: AppRobotoFontRegular, size: self.subHeadingLbl.font.pointSize)
        
    }
    
    func isLocationAccessEnabled() {
        
        //self.locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch CLLocationManager().authorizationStatus {
                case .notDetermined, .restricted, .denied:
                    print("No access of location")
                    
                    //self.locationManager?.delegate = self
                    //self.locationManager?.requestWhenInUseAuthorization()
                    //self.locationManager?.startUpdatingLocation()
                    //self.locationManager?.startMonitoringSignificantLocationChanges()
                    
                
                    self.locationManager.requestLocation(withDesiredAccuracy: .city, timeout: 10.0) { (currentLocation, achievedAccuracy, status) in
                        self.locationManager.cancelLocationRequest(INTULocationRequestID.init())
                    }
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access of location")
                
                //case .none:
                  //  print("Something wrong with location update")
                    //self.locationManager = nil
                    
                    break
                @unknown default:
                    print("Something wrong with location update")
                    //self.locationManager = nil
                    
                    break
                }
            } else {
                
                // Fallback on earlier versions
                //self.locationManager?.delegate = self
                //self.locationManager?.requestWhenInUseAuthorization()
                //self.locationManager?.startUpdatingLocation()
                //self.locationManager?.startMonitoringSignificantLocationChanges()
                
                
                self.locationManager.requestLocation(withDesiredAccuracy: .city, timeout: 10.0) { (currentLocation, achievedAccuracy, status) in
                    self.locationManager.cancelLocationRequest(INTULocationRequestID.init())
                }
                
            }
        } else {
            print("Location services are not enabled")
            
            //self.locationManager?.delegate = self
            //self.locationManager?.requestWhenInUseAuthorization()
            //self.locationManager?.startUpdatingLocation()
            //self.locationManager?.startMonitoringSignificantLocationChanges()
            
            
                self.locationManager.requestLocation(withDesiredAccuracy: .city, timeout: 10.0) { (currentLocation, achievedAccuracy, status) in
                self.locationManager.cancelLocationRequest(INTULocationRequestID.init())
            }
            
        }
        
    }
    
    //MARK:- LocationManager delegates methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.stopUpdatingLocation()
        //self.locationManager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        //self.locationManager = nil
    }
    
    //MARK:- bluetooth delegates methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            
            AppResultJSON["Bluetooth"].int = 1
            AppUserDefaults.setValue(true, forKey: "Bluetooth")
          
            break
        case .poweredOff:
            AppResultJSON["Bluetooth"].int = -1
            AppUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !AppResultString.contains("CISS04;") {
                AppResultString = AppResultString + "CISS04;"
            }
            
            break
        case .resetting:
            AppResultJSON["Bluetooth"].int = 0
            AppUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !AppResultString.contains("CISS04;") {
                AppResultString = AppResultString + "CISS04;"
            }
            
            break
        case .unauthorized:
            AppResultJSON["Bluetooth"].int = 0
            AppUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !AppResultString.contains("CISS04;") {
                AppResultString = AppResultString + "CISS04;"
            }
            
            break
        case .unsupported:
            AppResultJSON["Bluetooth"].int = 0
            AppUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !AppResultString.contains("CISS04;") {
                AppResultString = AppResultString + "CISS04;"
            }
            
            break
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // ***** STARTING ALL TESTS ***** //
            
            // 1. GSM Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                
                AppResultJSON["GSM"].int = 0
                AppUserDefaults.setValue(false, forKey: "GSM")
                AppResultString = AppResultString + "CISS10;"
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Network") + "..."
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                self.hud.progress = 0.2
                self.hud.show(in: self.view)
                
                if self.checkGSM() {
                    
                    if Luminous.Carrier.mobileCountryCode != nil {
                        AppResultJSON["GSM"].int = 1
                        AppUserDefaults.setValue(true, forKey: "GSM")
                        
                        if AppResultString.contains("CISS10;") {
                            AppResultString = AppResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                    
                    if Luminous.Carrier.mobileNetworkCode != nil {
                        AppResultJSON["GSM"].int = 1
                        AppUserDefaults.setValue(true, forKey: "GSM")
                        
                        if AppResultString.contains("CISS10;") {
                            AppResultString = AppResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                  
                    if Luminous.Carrier.ISOCountryCode != nil {
                        AppResultJSON["GSM"].int = 1
                        AppUserDefaults.setValue(true, forKey: "GSM")
                        
                        if AppResultString.contains("CISS10;") {
                            AppResultString = AppResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                    
                }else {
                    
                    AppResultJSON["GSM"].int = -2
                    AppUserDefaults.setValue(true, forKey: "GSM")
                    
                    if AppResultString.contains("CISS10;") {
                        AppResultString = AppResultString.replacingOccurrences(of: "CISS10;", with: "")
                    }
                    
                }
                
            }
            
   
            
            // 2. Bluetooth Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                AppResultJSON["Bluetooth"].int = 0
                AppUserDefaults.setValue(false, forKey: "Bluetooth")
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Bluetooth") + "..."
                self.hud.progress = 0.4
                
                switch self.blueToothManager.state {
                case .poweredOn:
                    
                    AppResultJSON["Bluetooth"].int = 1
                    AppUserDefaults.setValue(true, forKey: "Bluetooth")
                  
                    break
                case .poweredOff:
                    
                    AppResultJSON["Bluetooth"].int = -1
                    AppUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !AppResultString.contains("CISS04;") {
                        AppResultString = AppResultString + "CISS04;"
                    }
                    
                    break
                case .resetting:
                    
                    AppResultJSON["Bluetooth"].int = 0
                    AppUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !AppResultString.contains("CISS04;") {
                        AppResultString = AppResultString + "CISS04;"
                    }
                    
                    break
                case .unauthorized:
                    
                    AppResultJSON["Bluetooth"].int = 0
                    AppUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !AppResultString.contains("CISS04;") {
                        AppResultString = AppResultString + "CISS04;"
                    }
                    
                    break
                case .unsupported:
                    
                    AppResultJSON["Bluetooth"].int = 0
                    AppUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !AppResultString.contains("CISS04;") {
                        AppResultString = AppResultString + "CISS04;"
                    }
                    
                    break
                case .unknown:
                    break
                default:
                    break
                }
            
            }
       
        
            // 3. Storage Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                AppResultJSON["Storage"].int = 0
                AppUserDefaults.setValue(false, forKey: "Storage")
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Storage") + "..."
                self.hud.progress = 0.6
                
                if Luminous.Hardware.physicalMemory(with: .megabytes) > 1024.0 {
                    AppResultJSON["Storage"].int = 1
                    AppUserDefaults.setValue(true, forKey: "Storage")
                }else {
                    AppResultJSON["Storage"].int = 0
                    AppUserDefaults.setValue(false, forKey: "Storage")
                }
              
            
            }
    
        // 4. Battery Test
        
        AppResultJSON["Battery"].int = 1
        AppUserDefaults.setValue(true, forKey: "Battery")
        
        // 5. GPS Test
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            AppResultJSON["GPS"].int = 0
            AppUserDefaults.setValue(false, forKey: "GPS")
            
            self.gpsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            
        }
        
        
        
        /* // 6. NFC Test
        // Check if NFC supported
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                // available
                self.resultJSON["NFC"].int = 1
                userDefaults.setValue(true, forKey: "NFC")
            }
            else {
                // not
                self.resultJSON["NFC"].int = 0
                userDefaults.setValue(false, forKey: "NFC")
            }
        } else {
            //iOS don't support
            self.resultJSON["NFC"].int = -2
            userDefaults.setValue(false, forKey: "NFC")
        }
        */
    
       
    }
    
    @objc func runTimedCode() {
        
        self.count += 1
                
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking GPS") + "..."
        self.hud.progress = 0.8
        
        
        self.locationManager.requestLocation(withDesiredAccuracy: .city,
                                        timeout: 10.0,
                                        delayUntilAuthorized: true) { (currentLocation, achievedAccuracy, status) in
            
            if (status == INTULocationStatus.success) {
                
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location
                
                AppResultJSON["GPS"].int = 1
                AppUserDefaults.setValue(true, forKey: "GPS")
                
            }
            else if (status == INTULocationStatus.timedOut) {
                                
                // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                // However, currentLocation contains the best location available (if any) as of right now,
                // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                
                AppResultJSON["GPS"].int = 0
                AppUserDefaults.setValue(false, forKey: "GPS")
                
                if !AppResultString.contains("CISS04;") {
                    AppResultString = AppResultString + "CISS04;"
                }
                
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned.
                
                AppResultJSON["GPS"].int = 0
                AppUserDefaults.setValue(false, forKey: "GPS")
                
                if !AppResultString.contains("CISS04;") {
                    AppResultString = AppResultString + "CISS04;"
                }
                
            }
            
        }
        
        if count > 2 {
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Tests Complete !")
                self.hud.progress = 1.0
                
            }
        }
        
        if count > 3 {
            self.locationManager.cancelLocationRequest(INTULocationRequestID.init())
            
            //self.locationManager?.stopUpdatingLocation()
            //self.locationManager = nil
            
            self.gpsTimer?.invalidate()
            self.navigateToTestResultScreen()
        }
        
        
    }
    
    func navigateToTestResultScreen() {
        
        // ***** FINALISING ALL TESTS ***** //

        //DispatchQueue.main.async {
            
            self.hud.dismiss()
            
            //self.NavigateToDiagnoseTestResultVC()
            
            if self.isComingFromDiagnosticTestResult {
                                    
                guard let didFinishRetryDiagnosis = self.backgroundRetryDiagnosis else { return }
                didFinishRetryDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            else{
                                    
                guard let didFinishTestDiagnosis = self.backgroundTestDiagnosis else { return }
                didFinishTestDiagnosis()
                self.dismiss(animated: false, completion: nil)
                
            }
            
        //}
        
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
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension BackgroundTestsVC {

    func checkGSM() -> Bool {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            // Check if iOS Device supports phone calls
            // User will get an alert error when they will try to make a phone call in airplane mode
            
            
            if let mnc = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode, !mnc.isEmpty {
                // iOS Device is capable for making calls
                self.isCapableToCall = true
            } else {
                // Device cannot place a call at this time. SIM might be removed
                //self.isCapableToCall = false
                self.isCapableToCall = true
            }
        } else {
            // iOS Device is not capable for making calls
            self.isCapableToCall = false
        }
        
        print(isCapableToCall)
        return self.isCapableToCall
        
    }
    
}
