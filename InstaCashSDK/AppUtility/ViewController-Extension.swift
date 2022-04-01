//
//  ViewController.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON

extension UIViewController {
    
    func setStatusBarColor(themeColor : UIColor) {
        if #available(iOS 13.0, *) {
            
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = themeColor
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = themeColor
            
        }
    }
    
    
    func hideKeyboardWhenTappedAroundView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // To Save Language JSON
    func saveLocalizationString(_ langDict : NSDictionary) {
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("AppLanguage")
        let URL = NSURL.fileURL(withPath: destinationPath)
                
        let success = langDict.write(to: URL, atomically: true)
        print("write: ", success)
    }
    
    // To Get Language value according to key from saved JSON
    func getLocalizatioStringValue(key : String) -> String {
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("AppLanguage")
        let dict = NSDictionary.init(contentsOfFile: destinationPath)
        return (dict?.object(forKey: key) as? String ?? key)
    }

    
    func showaAlert(message: String, title: String = "") {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "OK"), style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = self.view.bounds
        
        alertController.view.tintColor = AppThemeColor
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showAlert(title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertAction.Style], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    {
        let alert = UIAlertController(title: title,message: message,preferredStyle: UIAlertController.Style.alert)
        
        for title in alertButtonTitles {
            let actionObj = UIAlertAction(title: title,
                                          style: alertButtonStyles[alertButtonTitles.firstIndex(of: title)!], handler: { action in
                                            completion(alertButtonTitles.firstIndex(of: action.title!)!)
            })
            
            alert.addAction(actionObj)
        }
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.view.bounds
        
        alert.view.tintColor = AppThemeColor
        //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
        vc.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UIViewController Navigation in SDK
    
    func NavigateToHomePage() {
        
        /*
        AppResultJSON = JSON()
        AppResultString = ""
        AppHardwareQuestionsData = nil
        hardwareQuestionsCount = 0
        AppQuestionIndex = -1
        self.resetAppUserDefaults()
        
        let StoreTokenVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreTokenVC") as! StoreTokenVC
            
        let nav = UINavigationController(rootViewController: self)
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = nav
        nav.navigationBar.isHidden = true
        nav.pushViewController(StoreTokenVC, animated: true)
        */
        
    }
    
    func resetAppUserDefaults() {
        let defaults = AppUserDefaults
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            
            if key != "imei_number" {
                if key != "SelectedLanguageSymbol" {
                    if key != "AppBaseUrl" {
                        defaults.removeObject(forKey: key)
                    }
                }
                
            }
            
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{0,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    /*
    func checkTestPerformSequence(index : Int, arrTests : [String]) -> (VCidentifier: String, VCname: UIViewController) {
        
        let testName = arrTests[index]
        
        switch testName {
        case "screen":
            return ("ScreenCalibrationVC", ScreenCalibrationVC())
        case "deadpixel":
            return ("DeadPixelsVC", DeadPixelsVC())
        case "speaker":
            return ("SpeakerVC", SpeakerVC())
        case "mic":
            return ("MicroPhoneVC", MicroPhoneVC())
        case "vibrator":
            return ("VibratorVC", VibratorVC())
        case "flashlight":
            return ("FlashLightVC", FlashLightVC())
        case "rotation":
            return ("AutoRotationVC", AutoRotationVC())
        case "proximity":
            return ("ProximityVC", ProximityVC())
        case "volumebutton":
            return ("VolumeButtonVC", VolumeButtonVC())
        case "earphone":
            return ("EarphoneVC", EarphoneVC())
        case "charger":
            return ("ChargerVC", ChargerVC())
        case "camera":
            return ("CameraVC", CameraVC())
        case "autofocus":
            return ("CameraVC", CameraVC())
        case "biometric":
            return ("BiometricVC", BiometricVC())
        case "wifi":
            return ("WiFiVC", WiFiVC())
        case "battery":
            return ("BackgroundTestsVC", BackgroundTestsVC())
        case "bluetooth":
            return ("BackgroundTestsVC", BackgroundTestsVC())
        case "gps":
            return ("BackgroundTestsVC", BackgroundTestsVC())
        case "gsm":
            return ("BackgroundTestsVC", BackgroundTestsVC())
        case "storage":
            return ("BackgroundTestsVC", BackgroundTestsVC())
        default:
            return ("", UIViewController())
        }
        
    }
    
    // MARK: UIViewController Navigation in SDK
    
    func NavigateToHomePageOfSDK() {
        
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiagnoseVC") as! DiagnoseVC
            
        let nav = UINavigationController(rootViewController: self)
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = nav
        nav.navigationBar.isHidden = true
        nav.pushViewController(homeVC, animated: true)
        
    }
    
    func NavigateToDiagnoseTestResultVC() {
        
        let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "DiagnosticTestResultVC") as! DiagnosticTestResultVC
        resultVC.modalPresentationStyle = .overFullScreen
        
        AppdidFinishRetryDiagnosis = {
            DispatchQueue.main.async() {
                self.NavigateToDiagnoseTestResultVC()
            }
        }
        
        self.present(resultVC, animated: true, completion: nil)
        
    }
    
    func NavigateToNextTestVC() {
        
        if SDKTestIndex < SDKTestsPerformArray.count {
            
            let vc = self.checkTestPerformSequence(index: SDKTestIndex, arrTests: SDKTestsPerformArray)
            let testVC = self.storyboard?.instantiateViewController(withIdentifier: "\(vc.VCidentifier)") ?? vc.VCname
            testVC.modalPresentationStyle = .overFullScreen
            
            AppdidFinishTestDiagnosis = {
                DispatchQueue.main.async() {
                    self.NavigateToNextTestVC()
                }
            }
            
            SDKTestIndex += 1
            self.present(testVC, animated: true, completion: nil)
            
        }else {
            
            self.NavigateToDiagnoseTestResultVC()
        }
        
    }
    */
    
    
}


struct AppOrientationUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        AppOrientationLock = orientation
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}
