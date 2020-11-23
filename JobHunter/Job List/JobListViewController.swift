//
//  JobListViewController.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import UIKit
import SafariServices

final class JobListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let activityView = UIActivityIndicatorView(style: .medium)

    var viewModel: JobListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = activityView
        activityView.hidesWhenStopped = true
        title = viewModel.sourceName
        fetchJobs()
    }
}

extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.jobs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobListTableViewCell", for: indexPath) as! JobListTableViewCell
        cell.displayInfo(using: viewModel.jobs[indexPath.row])
        return cell
    }
}

extension JobListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.jobs.count - 1 else { return }
        fetchMoreJobs()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let job = viewModel.jobs[indexPath.row]
        let safari = SFSafariViewController(url: job.url)
        present(safari, animated: true, completion: nil)
    }
}

private extension JobListViewController {
    func fetchJobs() {
        guard !viewModel.isFetchingJobs else { return }

        activityView.startAnimating()
        viewModel.fetchJobs { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }

    func fetchMoreJobs() {
        guard !viewModel.isFetchingJobs else { return }

        activityView.startAnimating()
        viewModel.fetchMoreJobs { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
}
