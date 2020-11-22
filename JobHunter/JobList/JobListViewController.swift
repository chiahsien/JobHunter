//
//  JobListViewController.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import UIKit

final class JobListViewController: UIViewController {
    private var jobs = [Job]()
    private let fetcher = MeetJobsFetcher()

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        fetcher.fetchJobs(at: 1) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(jobs):
                    self.jobs.append(contentsOf: jobs)
                    self.tableView.reloadData()
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}

extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobListTableViewCell", for: indexPath) as! JobListTableViewCell
        cell.displayInfo(using: jobs[indexPath.row])
        return cell
    }
}

extension JobListViewController: UITableViewDelegate {

}
