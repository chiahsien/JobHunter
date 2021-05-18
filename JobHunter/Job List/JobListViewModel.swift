//
//  JobListViewModel.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/23.
//

import Foundation
import Combine

final class JobListViewModel {
    private(set) var jobs = CurrentValueSubject<[Job], Never>([])
    private(set) var error = CurrentValueSubject<CustomError?, Never>(nil)
    private(set) var isFetchingJobs = CurrentValueSubject<Bool, Never>(false)
    private var cancellables = Set<AnyCancellable>()

    private let fetcher: Fetcher
    private var page: UInt = 0
    let sourceName: String

    init(fetcher: Fetcher) {
        self.fetcher = fetcher
        sourceName = fetcher.name
    }

    func fetchJobs() {
        fetchJobs(at: 1)
    }

    func fetchMoreJobs() {
        fetchJobs(at: page + 1)
    }

    private func fetchJobs(at page: UInt) {
        guard !isFetchingJobs.value else { return }

        error.value = nil
        isFetchingJobs.value = true

        fetcher.fetchJobs(at: page)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.error.value = error
                }
                self.isFetchingJobs.value = false
            } receiveValue: { [unowned self] jobs in
                self.jobs.value.append(contentsOf: jobs)
                self.page = page
            }
            .store(in: &cancellables)
    }
}
