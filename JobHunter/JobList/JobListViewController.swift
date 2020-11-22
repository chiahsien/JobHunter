//
//  JobListViewController.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import UIKit

final class JobListViewController: UIViewController {
    private let group = DispatchGroup()
    private let semaphore = DispatchSemaphore(value: 1)
    private let fetchers: [Fetcher] = [MeetJobsFetcher(), CakeResumeFetcher(), YouratorFetcher()]

    private var jobs = [Job]()
    private var page: UInt = 1
    private var isFetchingJobs = false

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        fetchJobs()
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !isFetchingJobs, indexPath.row == jobs.count - 1 else { return }
        fetchMoreJobs()
    }
}

private extension JobListViewController {
    func fetchJobs() {
        page = 1
        fetchJobs(at: page)
    }

    func fetchMoreJobs() {
        page += 1
        fetchJobs(at: page)
    }

    func fetchJobs(at page: UInt) {
        isFetchingJobs = true
        fetchers.forEach { (fetcher) in
            group.enter()
            fetcher.fetchJobs(at: page) { [weak self] (result) in
                guard let self = self else { return }

                switch result {
                case let .success(jobs):
                    self.semaphore.wait()
                    self.jobs.append(contentsOf: jobs)
                    self.semaphore.signal()

                case let .failure(error):
                    print(error)
                }

                self.group.leave()
            }
        }

        group.notify(queue: .main) {
            self.isFetchingJobs = false
            self.tableView.reloadData()
        }
    }
}