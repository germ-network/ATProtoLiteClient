//
//  GetDIDDocument.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 8/21/25.
//

import Foundation

extension ATProtoKitLite {
	public static func getHandle(
		did: String,
		pdsURL: URL
	) async throws -> String {
		// Add path
		var requestURL = pdsURL.appending(path: "/xrpc/com.atproto.repo.describeRepo")

		// Add query items
		let queryItems = [
			URLQueryItem(name: "repo", value: did)
		]
		requestURL = requestURL.appending(queryItems: queryItems)

		// Create and send the request to this URL
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.get.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		let (data, resp) = try await URLSession.shared.data(for: request)
		try ATProtoAPIErrorHandling.validate(data: data, resp: resp)

		// Decode the response data
		do {
			let describeRepositoryOutput = try JSONDecoder().decode(
				ComAtprotoLexiconLite.DescribeRepositoryOutput.self,
				from: data)
			guard describeRepositoryOutput.isHandleCorrect else {
				throw ATProtoAPIError.badHandle
			}
			return describeRepositoryOutput.repositoryHandle
		} catch {
			print(error)
			throw ATProtoAPIError.failedToDecodeJson
		}
	}
}
