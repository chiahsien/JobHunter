//
//  JobListTableViewCell.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/22.
//

import UIKit
import Kingfisher

class JobListTableViewCell: UITableViewCell {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var jobTitleLabel: UILabel!
    @IBOutlet private weak var companyLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var salaryLabel: UILabel!
    @IBOutlet private weak var tagsLabel: UILabel!

    private lazy var options: KingfisherOptionsInfo = [
        .processor(DownsamplingImageProcessor(size: logoImageView.frame.size)),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage,
        .transition(.fade(0.2)),
        .backgroundDecode
    ]

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.kf.cancelDownloadTask()
    }

    func displayInfo(using job: Job) {
        logoImageView.kf.indicatorType = .activity
        logoImageView.kf.setImage(with: job.logo, options: options)
        jobTitleLabel.text = job.title
        companyLabel.text = job.company
        if let location = job.location {
            locationLabel.text = "📍 " + location
        } else {
            locationLabel.text = nil
        }
        if let salary = job.salary {
            salaryLabel.text = "💰 " + salary
        } else {
            salaryLabel.text = nil
        }
        if let tags = job.tags, !tags.isEmpty {
            tagsLabel.text = "🏷️ " + tags.joined(separator: ", ")
        } else {
            tagsLabel.text = nil
        }
    }
}
