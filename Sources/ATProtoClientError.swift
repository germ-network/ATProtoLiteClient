//
//  ATProtoClientError.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import Foundation

enum ATProtoClientError: Error {
	case couldntFetchPDS
	case couldntFormPDSURL
	case missingLogin
	case missingOptional(String)
}

extension ATProtoClientError: LocalizedError {
	var localizedDescription: String {
		switch self {
		case .couldntFormPDSURL: "Couldn't form PDS URL"
		case .couldntFetchPDS: "Couldn't fetch PDS"
		case .missingLogin: "Missing login"
		case .missingOptional(let string): "Missing Optional\(string)"
		}
	}
}
