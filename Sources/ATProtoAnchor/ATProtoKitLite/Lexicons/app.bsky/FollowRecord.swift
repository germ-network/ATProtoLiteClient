//
//  FollowRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 8/21/25.
//
import Foundation

extension AppBskyLexiconLite {

	/// A record model for a follow.
	///
	/// - Note: According to the AT Protocol specifications: "Record declaring a social 'follow'
	/// relationship of another account. Duplicate follows will be ignored by the AppView."
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/follow.json
	public struct FollowRecord: ATRecordProtocolLite, Sendable {

		/// The identifier of the lexicon.
		///
		/// - Warning: The value must not change.
		public static let type: String = "app.bsky.graph.follow"

		/// The subject that the user account wants to "follow."
		public let subjectDID: String

		/// The date and time the block record was created.
		public let createdAt: Date

		public init(subjectDID: String, createdAt: Date) {
			self.subjectDID = subjectDID
			self.createdAt = createdAt
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			self.subjectDID = try container.decode(String.self, forKey: .subjectDID)
			self.createdAt = try container.decodeDateLite(forKey: .createdAt)
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)

			try container.encode(self.subjectDID, forKey: .subjectDID)
			try container.encodeDateLite(self.createdAt, forKey: .createdAt)
		}

		enum CodingKeys: String, CodingKey {
			case type = "$type"
			case subjectDID = "subject"
			case createdAt
		}
	}
}
