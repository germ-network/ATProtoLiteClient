//
//  RepoGetRecord.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 5/20/24.
//

import Foundation

extension ComAtprotoLexiconLite {

	/// A definition model for listing records.
	public struct ListRecords: Sendable, Codable {

		/// The URI of the record.
		public let uri: String

		/// The CID hash for the record.
		public let cid: String

		/// The value for the record.
		public let value: UnknownTypeLite?
	}

	public struct ListRecordsOutput: Sendable, Codable {

		/// The URI of the record.
		public let cursor: String?

		/// The value for the record.
		public let records: [ListRecords]
	}
}
