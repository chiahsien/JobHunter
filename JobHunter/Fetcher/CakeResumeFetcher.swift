//
//  CakeResumeFetcher.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import Foundation

struct CakeResumeFetcher: Fetcher {
    var name: String {
        return "CakeResume"
    }

    func fetchJobs(at page: UInt, completionHandler: @escaping (FetchResult<[Job]>) -> Void) {
        let parameters = "{\"requests\":[{\"indexName\":\"Job_order_by_content_updated_at\",\"params\":\"query=&page=\(page - 1)&maxValuesPerFacet=150&distinct=true&facets=%5B%22location_list%22%2C%22salary_type%22%2C%22salary_currency%22%2C%22salary_range%22\"}]}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://966rg9m3ek-dsn.algolia.net/1/indexes/*/queries?x-algolia-agent=Algolia%20for%20JavaScript%20(4.2.0)%3B%20Browser")!,timeoutInterval: 2000)
        request.addValue("OGRkODI5NGIwYjIxMzlkOTdlOGE1MjA0ZGM5ZjIyNjg0MTk1YWIzYmMwYmZiNzQ0ZDMxNWJlNWM0ZjY5ZjVlY3ZhbGlkVW50aWw9MTYwNjgyNDAzOSZyZXN0cmljdEluZGljZXM9Sm9iJTJDSm9iX29yZGVyX2J5X2NvbnRlbnRfdXBkYXRlZF9hdCUyQ0pvYl9wbGF5Z3JvdW5kJTJDUGFnZSUyQ1BhZ2Vfb3JkZXJfYnlfY29udGVudF91cGRhdGVkX2F0JmZpbHRlcnM9YWFzbV9zdGF0ZSUzQSslMjJjcmVhdGVkJTIyK0FORCtub2luZGV4JTNBK2ZhbHNlJmhpdHNQZXJQYWdlPTEwJmF0dHJpYnV0ZXNUb1NuaXBwZXQ9JTVCJTIyZGVzY3JpcHRpb25fcGxhaW5fdGV4dCUzQTgwJTIyJTVEJmhpZ2hsaWdodFByZVRhZz0lM0NtYXJrJTNFJmhpZ2hsaWdodFBvc3RUYWc9JTNDJTJGbWFyayUzRQ==", forHTTPHeaderField: "x-algolia-api-key")
        request.addValue("966RG9M3EK", forHTTPHeaderField: "x-algolia-application-id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        fetchContent(for: request, using: jobsParser, completionHandler: completionHandler)
    }

    private let jobsParser: Parser<Job> = { content in
        guard let jsonData = content.data(using: .utf8) else { return [] }
        let result = try JSONDecoder().decode(Result.self, from: jsonData)
        guard let hits = result.results.first?.hits else { return [] }
        let jobs: [Job] = hits.map { (cakeJob) -> Job in
            let urlString = "https://www.cakeresume.com/companies/\(cakeJob.page.path)/jobs/\(cakeJob.path)"
            var job = Job(title: cakeJob.title, company: cakeJob.page.name, url: URL(string: urlString)!, tags: cakeJob.tag_list)
            job.location = !cakeJob.location_list.isEmpty ? cakeJob.location_list.joined(separator: " ") : cakeJob.page.address
            job.logo = cakeJob.page.logo.medium

            var salary: String
            if cakeJob.salary_max == 0 {
                salary = "\(cakeJob.salary_min)+ \(cakeJob.salary_currency) / "
            } else {
                salary = "\(cakeJob.salary_min) - \(cakeJob.salary_max) \(cakeJob.salary_currency) / "
            }
            switch cakeJob.salary_type {
            case .perHour:
                salary.append("Hourly")
            case .perMonth:
                salary.append("Monthly")
            case .perYear:
                salary.append("Annually")
            }
            job.salary = salary

            return job
        }
        return jobs
    }
}

private extension CakeResumeFetcher {
    struct Result: Decodable {
        let results: [Hit]
    }

    struct Hit: Decodable {
        let hits: [CakeResumeJob]
    }

    struct CakeResumeJob: Decodable {
        enum SalaryType: String, Decodable {
            case perHour = "per_hour"
            case perMonth = "per_month"
            case perYear = "per_year"
        }
        let title: String
        let path: String
        let tag_list: [String]
        let location_list: [String]

        let salary_type: SalaryType
        let salary_currency: String
        let salary_min: Int
        let salary_max: Int

        let page: Company

        struct Company: Decodable {
            let name: String
            let path: String
            let address: String
            let logo: Logo
        }

        struct Logo: Decodable {
            let medium: URL
        }
    }
}
