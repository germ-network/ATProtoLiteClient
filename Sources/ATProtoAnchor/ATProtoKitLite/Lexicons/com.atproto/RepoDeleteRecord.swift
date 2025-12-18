//
//  RepoDeleteRecord.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 5/20/24.
//

import Foundation

extension ComAtprotoLexiconLite {

	/// A request body model for creating a record that replaces a previous record.
	///
	/// - Note: According to the AT Protocol specifications: "Write a repository record, creating
	/// or updating it as needed. Requires auth, implemented by PDS."
	///
	/// - SeeAlso: This is based on the [`com.atproto.repo.putRecord`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/putRecord.json
	public struct DeleteRecordRequestBody: Sendable {

		/// The decentralized identifier (DID) or handle of the repository.
		///
		/// - Note: According to the AT Protocol specifications: "The handle or DID of the repo
		/// (aka, current account)."
		public let repository: String

		/// The NSID of the record.
		///
		/// - Note: According to the AT Protocol specifications: "The NSID of the
		/// record collection."
		public let collection: String

		/// The record key of the collection.
		///
		/// - Note: According to the AT Protocol specifications: "The Record Key."
		public let recordKey: String

		enum CodingKeys: String, CodingKey {
			case repository = "repo"
			case collection
			case recordKey = "rkey"
		}

		public init(
			repository: String, collection: String, recordKey: String
		) {
			self.repository = repository
			self.collection = collection
			self.recordKey = recordKey
		}
	}
}

extension ComAtprotoLexiconLite.DeleteRecordRequestBody: Codable {}
