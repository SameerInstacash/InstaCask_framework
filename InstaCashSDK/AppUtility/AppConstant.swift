//
//  AppConstant.swift
//  InstaCashApp
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON

//var AppdidFinishTestDiagnosis: (() -> Void)?
//var AppdidFinishRetryDiagnosis: (() -> Void)?

var AppCurrentProductBrand = ""
var AppCurrentProductName = ""
var AppCurrentProductImage = ""

// ***** App Theme Color ***** //
var AppThemeColorHexString : String?
var AppThemeColor : UIColor = UIColor().HexToColor(hexString: AppThemeColorHexString ?? "#008F00", alpha: 1.0)

// ***** Font-Family ***** //
var AppFontFamilyName : String?

var AppRobotoFontRegular = "\(AppFontFamilyName ?? "Roboto")-Regular"
var AppRobotoFontMedium = "\(AppFontFamilyName ?? "Roboto")-Medium"
var AppRobotoFontBold = "\(AppFontFamilyName ?? "Roboto")-Bold"

// ***** Button Properties ***** //
var AppBtnCornerRadius : CGFloat = 10
var AppBtnTitleColorHexString : String?
var AppBtnTitleColor : UIColor = UIColor().HexToColor(hexString: AppBtnTitleColorHexString ?? "#FFFFFF", alpha: 1.0)

// ***** App Tests Performance ***** //
var holdAppTestsPerformArray = [String]()
var AppTestsPerformArray = [String]()
var AppTestIndex : Int = 0

let AppUserDefaults = UserDefaults.standard
var AppResultJSON = JSON()
var AppResultString = ""

var AppOrientationLock = UIInterfaceOrientationMask.all

