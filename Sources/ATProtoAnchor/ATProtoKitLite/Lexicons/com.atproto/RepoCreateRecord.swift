//
//  RepoCreateRecord.swift
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
	public struct CreateRecordRequestBody: Sendable {

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
		public let recordKey: String?

		/// Indicates whether the record should be validated. Optional.
		///
		/// - Note: According to the AT Protocol specifications: "Can be set to 'false' to skip
		/// Lexicon schema validation of record data, 'true' to require it, or leave unset to
		/// validate only for known Lexicons."
		public let shouldValidate: Bool?

		/// The record itself.
		///
		/// - Note: According to the AT Protocol specifications: "The record to write."
		public let record: UnknownTypeLite

		enum CodingKeys: String, CodingKey {
			case repository = "repo"
			case collection
			case recordKey = "rkey"
			case shouldValidate = "validate"
			case record
		}

		public init(
			repository: String, collection: String, recordKey: String?,
			shouldValidate: Bool? = nil, record: UnknownTypeLite
		) {
			self.repository = repository
			self.collection = collection
			self.recordKey = recordKey
			self.shouldValidate = shouldValidate
			self.record = record
		}
	}

	/// A output model for creating a record.
	///
	/// - Note: According to the AT Protocol specifications: "Create a single new repository record
	///  Requires auth, implemented by PDS."
	///
	/// - SeeAlso: This is based on the [`com.atproto.repo.createRecord`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/createRecord.json
	public struct CreateRecordOutput: Sendable, Codable {

		/// The URI of the record.
		public let uri: String

		/// The CID of the record.
		public let cid: String

		/// The status of the write operation's validation.
		public let validationStatus: ValidationStatus?

		/// The status of the write operation's validation.
		public enum ValidationStatus: String, Sendable, Codable {

			/// Status is valid.
			case valid

			/// Status is unknown.
			case unknown
		}
	}
}

extension ComAtprotoLexiconLite.CreateRecordRequestBody: Codable {
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.repository, forKey: .repository)
		try container.encode(self.collection, forKey: .collection)
		try container.truncatedEncodeIfPresentLite(
			self.recordKey, forKey: .recordKey, upToCharacterLength: 512)
		try container.encodeIfPresent(self.shouldValidate, forKey: .shouldValidate)
		try container.encode(self.record, forKey: .record)
	}
}
