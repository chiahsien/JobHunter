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
        viewModel.fetchJobs()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.activityView.stopAnimating()
                switch completion {
                case .finished:
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func fetchMoreJobs() {
        guard !viewModel.isFetchingJobs else { return }

        activityView.startAnimating()
        viewModel.fetchMoreJobs()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.activityView.stopAnimating()
                switch completion {
                case .finished:
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
