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

extension AppCoordinator: JobSourceViewControllerDelegate {
    func sourceViewController(_ viewController: JobSourceViewController, didSelect source: Fetcher) {
        let vc = createJobListViewController()
        let vm = JobListViewModel(fetcher: source)
        vc.viewModel = vm
        pushViewController(vc, animated: true)
    }
}

private extension AppCoordinator {
    func createSourceViewController() -> JobSourceViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JobSourceViewController") as! JobSourceViewController
        return vc
    }

    func createJobListViewController() -> JobListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "JobListViewController") as! JobListViewController
        return vc
    }
}
