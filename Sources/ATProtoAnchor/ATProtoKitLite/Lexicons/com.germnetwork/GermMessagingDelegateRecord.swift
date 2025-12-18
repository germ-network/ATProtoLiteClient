//
//  GermKeyPackageRecord.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 5/14/25.
//

import Foundation

extension GermLexicon {

	public struct MessagingDelegateRecord: ATRecordProtocolLite, Sendable {
		/// The identifier of the lexicon.
		///
		/// - Warning: The value must not change.
		public static let type: String = "com.germnetwork.declaration"
		private(set) var type: String = Self.type

		/// Required, Opaque.
		/// Expected to parse to a SemVer. While the lexicon is fixed, the version applies to the format of opaque content
		public let version: String

		/// Required, Opaque to AppViews (possible future - parse this and validate signature over the DID in keyPackage)
		/// ed25519 public key prefixed with a byte enum
		public let currentKey: Data

		/// Required, Opaque to AppViews
		/// Contains MLS KeyPackage(s), and other signature data, and is signed by the currentKey
		public let keyPackage: Data?

		/// Optional
		/// Encapsulates the required url and `showButtonTo`  properties to show a button to other users
		public let messageMe: MessageMeInstructions?

		/// Optional, Opaque.
		/// Allows for key rolling
		public let continuityProofs: [Data]?

		enum CodingKeys: String, CodingKey {
			case type = "$type"
			case version
			case currentKey
			case keyPackage
			case messageMe
			case continuityProofs
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			self.type = try container.decode(String.self, forKey: CodingKeys.type)
			guard self.type == Self.type else {
				throw ATProtoAPIError.unexpectedRecordType
			}

			self.version = try container.decode(String.self, forKey: CodingKeys.version)
			self.currentKey = try container.decode(
				Data.self, forKey: CodingKeys.currentKey)
			self.keyPackage = try container.decodeIfPresent(
				Data.self, forKey: CodingKeys.keyPackage)
			self.messageMe = try container.decodeIfPresent(
				MessageMeInstructions.self, forKey: CodingKeys.messageMe)
			self.continuityProofs = try container.decodeIfPresent(
				[Data].self, forKey: CodingKeys.continuityProofs)
		}

		public init(
			version: String,
			currentKey: Data,
			keyPackage: Data?,
			messageMe: MessageMeInstructions?,
			continuityProofs: [Data]?
		) {
			self.version = version
			self.currentKey = currentKey
			self.keyPackage = keyPackage
			self.messageMe = messageMe
			self.continuityProofs = continuityProofs
		}
	}

	public struct MessageMeInstructions: Sendable, Codable, Equatable, Hashable {
		/// Required
		/// The policy of who can message the user is contained in the keyPackage and is covered by a
		/// signature by the currentKey.
		/// Lifting this out of the opaque keyPackage so the AppView can use it to decide when to render
		/// a link when others view this user’s profile
		public let showButtonTo: ShowButtonTo

		/// Required
		/// This is the url to present to a user Bob who does not have a "com.germnetwork.id" record of their own
		/// This should parse as a URI with empty fragment, where the app should fill in the fragment with
		/// Alice and Bob’s DID’s (see above).
		public let messageMeUrl: String

		public init(
			showButtonTo: ShowButtonTo,
			messageMeUrl: String
		) {
			self.showButtonTo = showButtonTo
			self.messageMeUrl = messageMeUrl
		}
	}

	public enum ShowButtonTo: String, Sendable, Codable {
		case usersIFollow
		case everyone
	}
}
