//
//  FetcherProtocol.swift
//  JobHunter
//
//  Created by Nelson on 2020/11/18.
//

import Foundation
import Combine

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
    case serverError(code: Int)
    case clientError(code: Int)
    case otherResponseError(code: Int)
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
    func fetchJobs(at page: UInt) -> AnyPublisher<[Job], CustomError>
}

internal extension Fetcher {
    func fetchContent<T>(for request: URLRequest, encoding: String.Encoding = .utf8, using parser: @escaping Parser<T>) -> AnyPublisher<[T], CustomError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                let response = response as! HTTPURLResponse
                switch response.statusCode {
                case 200..<300:
                    return data
                case 400..<500:
                    throw CustomError.clientError(code: response.statusCode)
                case 500..<600:
                    throw CustomError.serverError(code: response.statusCode)
                default:
                    throw CustomError.otherResponseError(code: response.statusCode)
                }
            }
            .tryMap { data -> String in
                guard let content = String(data: data, encoding: encoding) else {
                    throw CustomError.invalidData(data)
                }
                return content
            }
            .tryMap { content -> [T] in
                do {
                    let parseResult = try parser(content)
                    if parseResult.isEmpty {
                        throw CustomError.emptyData
                    } else {
                        return parseResult
                    }
                } catch {
                    throw CustomError.parseError(error)
                }
            }
            .mapError { error in
                return (error as? CustomError) ?? CustomError.networkError(error)
            }
            .eraseToAnyPublisher()
    }

    func fetchContent<T>(for request: URLRequest, encoding: String.Encoding = .utf8, using parser: @escaping Parser<T>, completionHandler: @escaping (FetchResult<[T]>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                let result = FetchResult<[T]>.failure(.networkError(error!))
                completionHandler(result)
                return
            }

            switch response.statusCode {
            case 400..<500:
                let result = FetchResult<[T]>.failure(.clientError(code: response.statusCode))
                completionHandler(result)
                return
            case 500..<600:
                let result = FetchResult<[T]>.failure(.serverError(code: response.statusCode))
                completionHandler(result)
                return
            default:
                break
            }

            guard let content = String(data: data, encoding: encoding) else {
                let result = FetchResult<[T]>.failure(.invalidData(data))
                completionHandler(result)
                return
            }

            do {
                let parseResult = try parser(content)
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
