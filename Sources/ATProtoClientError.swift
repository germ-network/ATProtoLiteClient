//
//  ATProtoClientError.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import Foundation

enum ATProtoClientError: Error {
	case missingLogin
	case missingOptional(String)
}

extension ATProtoClientError: LocalizedError {
	var localizedDescription: String {
		switch self {
		case .missingLogin: "Missing login"
		case .missingOptional(let string): "Missing Optional\(string)"
		}
	}
}
