//
//  JobListViewModel.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/23.
//

import Foundation
import Combine

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

    func fetchJobs() -> AnyPublisher<Never, CustomError> {
        fetchJobs(at: 1)
    }

    func fetchMoreJobs() -> AnyPublisher<Never, CustomError> {
        fetchJobs(at: page + 1)
    }

    private func fetchJobs(at page: UInt) -> AnyPublisher<Never, CustomError> {
        fetcher.fetchJobs(at: page)
            .handleEvents(receiveSubscription: { _ in
                self.error = nil
                self.isFetchingJobs = true
            }, receiveOutput: { jobs in
                self.jobs.append(contentsOf: jobs)
                self.page = page
            }, receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.error = error
                }
                self.isFetchingJobs = false
            })
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}
