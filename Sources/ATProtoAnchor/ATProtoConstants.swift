//
//  ATProtoConstants.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 2/24/25.
//

import Foundation
import OAuthenticator

struct ATProtoConstants {
	static let publicAPI = "https://public.api.bsky.app"
	struct OAuth {
		static let baseHost = "bsky.social"
		static let clientId = "https://static.germnetwork.com/client-metadata.json"
	}
	// Arbitrary value to prevent infinite loops
	static let maxFetches = 2 * Int(pow(Double(10), Double(9)))
}

public enum ATProtoAPIError: Error, Equatable, LocalizedError {
	case badHandle
	case badRequest
	case badResponse(error: String?, message: String?, statusCode: Int?)
	case badUrl
	case failedToEncode
	case failedToDecodeJson
	case failedToDecodeRecord
	case recordNotFound
	case notImplemented
	case unexpectedRecordType

	public var errorDescription: String? {
		switch self {
		case .badHandle: "Bad handle"
		case .badRequest: "Bad request"
		case .badResponse: "Bad response"
		case .badUrl: "Bad URL"
		case .failedToEncode: "Failed to encode"
		case .failedToDecodeJson: "Failed to decode JSON"
		case .failedToDecodeRecord: "Failed to decode record"
		case .recordNotFound: "Record not found"
		case .notImplemented: "Not implemented"
		case .unexpectedRecordType: "Unexpected type for record"
		}
	}
}

public enum ATProtoSessionError: Error, Equatable, LocalizedError {
	case invalidRequest
	case expiredToken
	case invalidToken
	case accountTakedown

	public var errorDescription: String? {
		switch self {
		case .invalidRequest: "Invalid request"
		case .expiredToken: "Expired token"
		case .invalidToken: "Invalid token"
		case .accountTakedown: "Account takedown"
		}
	}
}

public enum ATProtoAPIErrorHandling {
	struct HTTPResponse: Codable {
		let error: String
		let message: String
	}

	static func validate(data: Data, resp: URLResponse) throws {
		let httpResponse = resp as? HTTPURLResponse
		guard httpResponse?.statusCode == 200 else {
			// If we can decode the error, we can throw more specific errors
			if let errorResponse = try? JSONDecoder().decode(
				ATProtoAPIErrorHandling.HTTPResponse.self,
				from: data
			) {
				switch errorResponse.error {
				case "RecordNotFound":
					throw ATProtoAPIError.recordNotFound
				case "InvalidRequest":
					throw ATProtoSessionError.invalidRequest
				case "ExpiredToken":
					throw ATProtoSessionError.expiredToken
				case "InvalidToken":
					throw ATProtoSessionError.invalidToken
				case "AccountTakedown":
					throw ATProtoSessionError.accountTakedown
				default:
					throw ATProtoAPIError.badResponse(
						error: errorResponse.error,
						message: errorResponse.message,
						statusCode: httpResponse?.statusCode
					)
				}
			}
			throw ATProtoAPIError.badResponse(
				error: nil,
				message: String(data: data, encoding: .utf8),
				statusCode: httpResponse?.statusCode
			)
		}
	}
}
