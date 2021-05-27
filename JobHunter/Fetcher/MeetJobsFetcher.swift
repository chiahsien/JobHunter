//
//  MeetJobsFetcher.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/20.
//

import Foundation
import Combine

struct MeetJobsFetcher: Fetcher {
    var name: String {
        return "meet.jobs"
    }

    func fetchJobs(at page: UInt) -> AnyPublisher<[Job], CustomError> {
        let urlString = "https://api.meet.jobs/api/v1/jobs?page=\(page)&order=update&include=required_skills&external_job=true"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"

        return fetchContent(for: request, using: jobsParser)
    }

    private let jobsParser: Parser<Job> = { content in
        guard let jsonData = content.data(using: .utf8) else { return [] }
        let result = try JSONDecoder().decode(Result.self, from: jsonData)
        let jobs: [Job] = result.collection.map { (meetjob) -> Job in
            let company = meetjob.employer?.name ?? meetjob.external_employer_name ?? ""
            let encodedSlug = meetjob.slug.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let urlString = "https://meet.jobs/zh-TW/jobs/\(meetjob.id)-\(encodedSlug)"
            var job = Job(title: meetjob.title, company: company, url: URL(string: urlString)!)
            job.location = meetjob.address.handwriting_city
            job.logo = meetjob.employer?.logo.url ?? meetjob.external_employer_logo_url
            job.tags = meetjob.required_skills?.map { $0.name }

            var salary: String
            if meetjob.salary.maximum != nil {
                salary = "\(meetjob.salary.minimum) - \(meetjob.salary.maximum!)"
            } else {
                salary = "\(meetjob.salary.minimum)+"
            }
            job.salary = "\(salary) \(meetjob.salary.currency) / \(meetjob.salary.paid_period)"

            return job
        }
        return jobs
    }
}

private extension MeetJobsFetcher {
    struct Result: Decodable {
        let collection: [MeetJob]
    }

    struct MeetJob: Decodable {
        let id: Int
        let employer: Company?
        let title: String
        let required_skills: [Tag]?
        let salary: Salary
        let slug: String
        let address: Address
        let external_employer_logo_url: URL?
        let external_employer_name: String?
    }

    struct Company: Decodable {
        let name: String
        let logo: Logo
    }

    struct Logo: Decodable {
        let url: URL
    }

    struct Tag: Decodable {
        let name: String
    }

    struct Salary: Decodable {
        let currency: String
        let minimum: Int
        let maximum: Int?
        let paid_period: String
    }

    struct Address: Decodable {
        let handwriting_city: String
    }
}
