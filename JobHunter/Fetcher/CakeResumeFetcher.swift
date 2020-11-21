//
//  CakeResumeFetcher.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import Foundation
import SwiftSoup

struct CakeResumeFetcher: Fetcher {
    var name: String {
        return "Cake Resume"
    }

    func fetchJobs(at page: UInt, completionHandler: @escaping (FetchResult<[Job]>) -> Void) {
        let path = "https://www.cakeresume.com/jobs?refinementList%5Border%5D=latest&page=\(page)"
        fetchContent(at: URL(string: path)!, using: jobsParser, completionHandler: completionHandler)
    }

    private let jobsParser: Parser<Job> = { html in
        let document: Document = try SwiftSoup.parse(html)
        let query = "div.job > div.job-item"
        let elements = try document.select(query)

        let jobs = elements.array().compactMap { e -> Job? in
            guard let titleNode = try? e.select(".job-list-item-content > .job-title > .job-link-wrapper").first(),
                  let companyNode = try? e.select(".job-list-item-content > .page-name").first(),
                  let urlNode = try? e.select(".job-list-item-content > .job-title .job-link-wrapper > a").first()
            else { return nil }

            guard let title = try? titleNode.text(),
                  let company = try? companyNode.text(),
                  let url = try? urlNode.absUrl("href")
            else { return nil }

            var job = Job(title: title, company: company, url: URL(string: url)!)
            if let salary = try? e.select(".job-salary").first()?.text() {
                job.salary = salary
            }

            if let logo = try? e.select(".job-list-item-content > .job-title > .company-logo-wrapper > img").first()?.attr("src") {
                job.logo = URL(string: logo)
            }

            if let location = try? e.select(".job-list-item-tags .location-section").text() {
                job.location = location
            }
            return job
        }
        return jobs
    }
}
