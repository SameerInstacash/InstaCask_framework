//  TestResultCell.swift
//  TechCheck
//
//  Created by TechCheck on 25/09/18.
//  Copyright © 2018 Prakhar Gupta. All rights reserved.

import UIKit

class TestResultCell: UITableViewCell {
    
    @IBOutlet weak var lblReTry: UILabel!
    @IBOutlet weak var imgReTry: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblSeperator: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        DispatchQueue.main.async {
            self.layer.cornerRadius = 0.0
            self.lblSeperator.isHidden = false
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
