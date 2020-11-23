//
//  JobSourceViewController.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/23.
//

import UIKit

protocol JobSourceViewControllerDelegate: AnyObject {
    func sourceViewController(_ viewController: JobSourceViewController, didSelect source: Fetcher)
}

final class JobSourceViewController: UIViewController {
    weak var delegate: JobSourceViewControllerDelegate?

    @IBOutlet private weak var tableView: UITableView!
    private let sources: [Fetcher] = [MeetJobsFetcher(), CakeResumeFetcher(), YouratorFetcher()]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Job Hunter"
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
}

extension JobSourceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobSourceCell", for: indexPath)
        cell.textLabel?.text = sources[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.sourceViewController(self, didSelect: sources[indexPath.row])
    }
}
