//
//  AppCoordinator.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/23.
//

import UIKit

final class AppCoordinator: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let vc = createSourceViewController()
        vc.delegate = self
        viewControllers = [vc]
    }
}

private extension AppCoordinator {
    func createSourceViewController() -> JobSourceViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JobSourceViewController") as! JobSourceViewController
        return vc
    }
}
