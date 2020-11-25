//
//  YouratorFetcher.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/20.
//

import Foundation

struct YouratorFetcher: Fetcher {
    var name: String {
        return "Yourator"
    }

    func fetchJobs(at page: UInt, completionHandler: @escaping (FetchResult<[Job]>) -> Void) {
        let path = "https://www.yourator.co/api/v2/jobs?page=\(page)"
        fetchContent(at: URL(string: path)!, using: jobsParser, completionHandler: completionHandler)
    }

    private let jobsParser: Parser<Job> = { content in
        guard let jsonData = content.data(using: .utf8) else { return [] }
        let result = try JSONDecoder().decode(Result.self, from: jsonData)
        let jobs: [Job] = result.jobs.map { (youratorJob) in
            var job = Job(title: youratorJob.title, company: youratorJob.company.brand, url: youratorJob.url)
            job.salary = youratorJob.salary
            job.location = youratorJob.city
            job.logo = youratorJob.company.banner
            job.tags = youratorJob.tags?.map { $0.name }
            return job
        }
        return jobs
    }
}

private extension YouratorFetcher {
    struct Result: Decodable {
        let jobs: [YouratorJob]
    }

    struct YouratorJob: Decodable {
        let title: String
        let url: URL
        let tags: [Tag]?
        let salary: String?
        let city: String?
        let company: Company

        enum CodingKeys: String, CodingKey {
            case title = "name"
            case url = "path"
            case tags
            case salary
            case city
            case company
        }

        struct Tag: Decodable {
            let name: String
        }

        struct Company: Decodable {
            let brand: String
            let banner: URL?
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            let partialURL = try container.decode(String.self, forKey: .url)
            url = URL(string: partialURL, relativeTo: URL(string: "https://yourator.co")!)!
            tags = try container.decodeIfPresent([Tag].self, forKey: .tags)
            salary = try container.decodeIfPresent(String.self, forKey: .salary)
            city = try container.decodeIfPresent(String.self, forKey: .city)
            company = try container.decode(Company.self, forKey: .company)
        }
    }
}
