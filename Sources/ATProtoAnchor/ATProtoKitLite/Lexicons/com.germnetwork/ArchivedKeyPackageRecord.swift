//
//  GermKeyPackageRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 5/14/25.
//

import Foundation

extension GermLexicon {

	public struct ArchivedKeyPackageRecord: ATRecordProtocolLite, Sendable {
		/// The identifier of the lexicon.
		///
		/// - Warning: The value must not change.
		public static let type: String = "com.germnetwork.keypackage"
		private(set) var type: String = Self.type

		public let anchorHello: Data

		public init(anchorHello: Data) {
			self.anchorHello = anchorHello
		}

		enum CodingKeys: String, CodingKey {
			case type = "$type"
			case anchorHello
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			self.type = try container.decode(String.self, forKey: CodingKeys.type)
			guard self.type == Self.type else {
				throw ATProtoAPIError.unexpectedRecordType
			}

			self.anchorHello = try container.decode(
				Data.self, forKey: CodingKeys.anchorHello)
		}
	}
}
