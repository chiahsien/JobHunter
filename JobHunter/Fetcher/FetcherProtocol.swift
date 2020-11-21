//
//  FetcherProtocol.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import Foundation

struct Job {
    let title: String
    let company: String
    let url: URL
    var salary: String?
    var logo: URL?
    var location: String?
    var tags: [String]?
}

enum CustomError: Error {
    case networkError(_: Error)
    case parseError(_: Error)
    case invalidData(_: Data)
    case emptyData
}

enum FetchResult<Value> {
    case success(Value)
    case failure(CustomError)
}

typealias Parser<T> = (_ content: String) throws -> [T]

protocol Fetcher {
    var name: String { get }
    func fetchJobs(at page: UInt, completionHandler: @escaping (FetchResult<[Job]>) -> Void)
}

internal extension Fetcher {
    func fetchContent<T>(at url: URL, encoding: String.Encoding = .utf8, using parser: @escaping Parser<T>, completionHandler: @escaping (FetchResult<[T]>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                let result = FetchResult<[T]>.failure(.networkError(error!))
                completionHandler(result)
                return
            }

            guard let html = String(data: data, encoding: encoding) else {
                let result = FetchResult<[T]>.failure(.invalidData(data))
                completionHandler(result)
                return
            }

            do {
                let parseResult = try parser(html)
                let result: FetchResult<[T]> = (parseResult.isEmpty ? .failure(.emptyData) : .success(parseResult))
                completionHandler(result)
            } catch {
                let result: FetchResult<[T]> = .failure(.parseError(error))
                completionHandler(result)
            }
        }
        task.resume()
    }
}
