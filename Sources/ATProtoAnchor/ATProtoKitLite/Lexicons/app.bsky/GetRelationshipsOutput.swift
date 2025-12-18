//
//  Relationship.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 9/15/25.
//

extension AppBskyLexiconLite {
	public struct GetRelationshipsOutput: Sendable, Decodable {
		public let actorDID: String
		public let relationships: [GetRelationshipsOutputRelationshipUnion]

		enum CodingKeys: String, CodingKey {
			case actorDID = "actor"
			case relationships
		}
	}
}

extension AppBskyLexiconLite {
	/// A reference containing the list of relationships of multiple user accounts.
	public enum GetRelationshipsOutputRelationshipUnion: Sendable, Codable {

		/// The relationship between two user accounts.
		case relationship(RelationshipDefinition)

		/// Indicates the user account is not found.
		case notFoundActor(NotFoundActorDefinition)

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()

			if let value = try? container.decode(RelationshipDefinition.self) {
				self = .relationship(value)
			} else if let value = try? container.decode(NotFoundActorDefinition.self) {
				self = .notFoundActor(value)
			} else {
				throw DecodingError.typeMismatch(
					GetRelationshipsOutputRelationshipUnion.self,
					DecodingError.Context(
						codingPath: decoder.codingPath,
						debugDescription:
							"Unknown GetRelationshipsOutputRelationshipUnion type"
					))
			}
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()

			switch self {
			case .relationship(let relationship):
				try container.encode(relationship)
			case .notFoundActor(let notFoundActor):
				try container.encode(notFoundActor)
			}
		}
	}
	/// A definition model for a user that may not have been found in the user list.
	///
	/// - SeeAlso: This is based on the [`app.bsky.graph.defs`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/defs.json
	public struct NotFoundActorDefinition: Sendable, Codable {
		/// The URI of the user.
		///
		/// - Note: According to the AT Protocol specifications: "indicates that a handle or DID
		/// could not be resolved".
		public let actorURI: String

		/// Indicates whether the user is not found. (default: true)
		public let isNotFound: Bool

		enum CodingKeys: String, CodingKey {
			case actorURI = "actor"
			case isNotFound = "notFound"
		}
	}

	/// A definition model for a graph relationship between two user accounts.
	///
	/// - Note: According to the AT Protocol specifications: "lists the bi-directional graph
	/// relationships between one actor (not indicated in the object), and the target actors (the
	/// DID included in the object)"
	///
	/// - SeeAlso: This is based on the [`app.bsky.graph.defs`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/defs.json
	public struct RelationshipDefinition: Sendable, Codable {

		/// The decentralized identifier (DID) of the target user.
		public let actorDID: String

		/// The URI of the follow record, if the first user is following the target user. Optional.
		///
		/// - Note: According to the AT Protocol specifications: "if the actor follows this DID, this
		/// is the AT-URI of the follow record"
		public let followingURI: String?

		/// The URI of the follow record, if the target user is following the first user. Optional.
		///
		/// - Note: According to the AT Protocol specifications: "if the actor is followed by this
		/// DID, contains the AT-URI of the follow record"
		public let followedByURI: String?

		enum CodingKeys: String, CodingKey {
			case actorDID = "did"
			case followingURI = "following"
			case followedByURI = "followedBy"
		}
	}
}
