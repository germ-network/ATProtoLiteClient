//
//  RefreshSessionOutput.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/18/25.
//  From the ComAtprotoLabelDefs.swift file by Christopher Jr Riley on 5/20/24.
//

import Foundation

extension ComAtprotoLexiconLite {
	public struct RefreshSessionOutput: Sendable, Codable {
		public let accessJwt: String

		public let refreshJwt: String

		public let handle: String

		public let did: String

		public let didDoc: DIDDocument?

		public let active: Bool?

		// Hosting status of the account.
		// If the status isn't specified, assume "active"
		public let status: StatusValue?
	}

	public enum StatusValue: String, Sendable, Codable {
		case takendown
		case suspended
		case deactivated
	}
}
