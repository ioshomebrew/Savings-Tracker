//
//  GoalViewCell.swift
//  Savings Tracker
//
//  Created by Beecher Adams on 11/6/16.
//  Copyright © 2016 Beecher Adams. All rights reserved.
//

import UIKit

class GoalViewCell: UITableViewCell {
    @IBOutlet var progressView: UIProgressView!;
    @IBOutlet var nameLabel: UILabel!;
    @IBOutlet var amountLabel: UILabel!;
    @IBOutlet var percentLabel: UILabel!;
    @IBOutlet var timeLabel: UILabel!;
}
