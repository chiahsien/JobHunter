//
//  JobListViewController.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import UIKit
import Combine
import SafariServices

final class JobListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    var viewModel: JobListViewModel!
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.hidesWhenStopped = true
        title = viewModel.sourceName
        setupBinding()
        fetchJobs()
    }
}

extension JobListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.jobs.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobListTableViewCell", for: indexPath) as! JobListTableViewCell
        cell.displayInfo(using: viewModel.jobs.value[indexPath.row])
        return cell
    }
}

extension JobListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.jobs.value.count - 1 else { return }
        fetchMoreJobs()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let job = viewModel.jobs.value[indexPath.row]
        let safari = SFSafariViewController(url: job.url)
        present(safari, animated: true, completion: nil)
    }
}

private extension JobListViewController {
    func setupBinding() {
        viewModel.isFetchingJobs
            .receive(on: DispatchQueue.main)
            .sink { [activityView] fetching in
                fetching ? activityView?.startAnimating() : activityView?.stopAnimating()
            }
            .store(in: &cancellables)

        viewModel.error
            .receive(on: DispatchQueue.main)
            .sink { error in
                if (error != nil) {
                    print("Error: \(error!)")
                }
            }
            .store(in: &cancellables)

        viewModel.jobs
            .receive(on: DispatchQueue.main)
            .sink { [tableView] _ in
                tableView?.reloadData()
            }
            .store(in: &cancellables)
    }

    func fetchJobs() {
        viewModel.fetchJobs()
    }

    func fetchMoreJobs() {
        viewModel.fetchMoreJobs()
    }
}
