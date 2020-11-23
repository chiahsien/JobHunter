//
//  JobListViewModel.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/23.
//

import Foundation

final class JobListViewModel {
    private(set) var jobs = [Job]()
    private(set) var error: CustomError? = nil
    private(set) var isFetchingJobs = false
    private let fetcher: Fetcher
    private var page: UInt = 0
    let sourceName: String

    init(fetcher: Fetcher) {
        self.fetcher = fetcher
        sourceName = fetcher.name
    }

    func fetchJobs(_ completionHandler: @escaping () -> Void) {
        fetchJobs(at: 1, completionHandler: completionHandler)
    }

    func fetchMoreJobs(_ completionHandler: @escaping () -> Void) {
        fetchJobs(at: page + 1, completionHandler: completionHandler)
    }

    private func fetchJobs(at page: UInt, completionHandler: @escaping () -> Void) {
        error = nil
        isFetchingJobs = true

        fetcher.fetchJobs(at: page) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case let .success(jobs):
                self.jobs.append(contentsOf: jobs)
                self.page = page

            case let .failure(error):
                self.error = error
            }

            self.isFetchingJobs = false
            completionHandler()
        }
    }
}
