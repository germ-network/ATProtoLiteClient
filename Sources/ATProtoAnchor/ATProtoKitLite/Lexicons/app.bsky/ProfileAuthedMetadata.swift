//
//  ProfileAuthedMetadata.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 9/24/25.
//

import Foundation

extension AppBskyLexiconLite {

	/// A definition model for a profile view.
	///
	/// - SeeAlso: This is based on the [`app.bsky.actor.defs`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/actor/defs.json
	public struct ProfileAuthedMetadata: Sendable, Codable, Equatable, Hashable {

		/// The decentralized identifier (DID) of the user.
		public let actorDID: String

		/// The unique handle of the user.
		//		public let actorHandle: String

		/// The display name of the user's profile. Optional.
		///
		/// - Important: Current maximum length is 64 characters.
		//		public let displayName: String?

		/// The description of the user's profile. Optional.
		///
		/// - Important: Current maximum length is 256 characters.
		//		public let description: String?

		/// The avatar image URL of a user's profile. Optional.
		//		public let avatarImageURL: URL?

		/// The associated profile view. Optional.
		//		public let associated: ProfileAssociatedDefinition?

		/// The date the profile was last indexed. Optional.
		//		public let indexedAt: Date?

		/// The date and time the profile was created. Optional.
		//		public let createdAt: Date?

		/// The list of metadata relating to the requesting account's relationship with the
		/// subject account. Optional.
		public let viewer: ViewerStateDefinition?

		/// An array of labels created by the user. Optional.
		//		public let labels: [ComAtprotoLexicon.Label.LabelDefinition]?

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			self.actorDID = try container.decode(String.self, forKey: .actorDID)
			//			self.actorHandle = try container.decode(String.self, forKey: .actorHandle)
			//			self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
			//			self.description = try container.decodeIfPresent(String.self, forKey: .description)
			//			self.avatarImageURL = try container.decodeIfPresent(URL.self, forKey: .avatarImageURL)
			//			self.associated = try container.decodeIfPresent(AppBskyLexicon.Actor.ProfileAssociatedDefinition.self, forKey: .associated)
			//			self.indexedAt = try container.decodeDateIfPresent(forKey: .indexedAt)
			//			self.createdAt = try container.decodeDateIfPresent(forKey: .createdAt)
			self.viewer = try container.decodeIfPresent(
				AppBskyLexiconLite.ViewerStateDefinition.self, forKey: .viewer)
			//			self.labels = try container.decodeIfPresent([ComAtprotoLexicon.Label.LabelDefinition].self, forKey: .labels)
		}

		@_documentation(visibility: private)
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)

			try container.encode(self.actorDID, forKey: .actorDID)
			//			try container.encode(self.actorHandle, forKey: .actorHandle)
			//			try container.truncatedEncodeIfPresent(self.displayName, forKey: .displayName, upToCharacterLength: 64)
			//			try container.truncatedEncodeIfPresent(self.description, forKey: .description, upToCharacterLength: 256)
			//			try container.encodeIfPresent(self.avatarImageURL, forKey: .avatarImageURL)
			//			try container.encodeIfPresent(self.associated, forKey: .associated)
			//			try container.encodeDateIfPresent(self.indexedAt, forKey: .indexedAt)
			//			try container.encodeDateIfPresent(self.createdAt, forKey: .createdAt)
			try container.encodeIfPresent(self.viewer, forKey: .viewer)
			//			try container.encodeIfPresent(self.labels, forKey: .labels)
		}

		enum CodingKeys: String, CodingKey {
			case actorDID = "did"
			//			case actorHandle = "handle"
			//			case displayName
			//			case description
			//			case avatarImageURL = "avatar"
			//			case associated
			//			case indexedAt
			//			case createdAt
			case viewer
			//			case labels
		}
	}

	/// A definition model for an actor viewer state.
	///
	/// - Note: From the AT Protocol specification: "Metadata about the requesting account's
	/// relationship with the subject account. Only has meaningful content for authed requests."
	///
	/// - SeeAlso: This is based on the [`app.bsky.actor.defs`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/actor/defs.json
	public struct ViewerStateDefinition: Sendable, Codable, Equatable, Hashable {

		/// Indicates whether the requesting account has been muted by the subject
		/// account. Optional.
		public let isMuted: Bool?

		/// An array of lists that the subject account is muted by.
		//		public let mutedByArray: AppBskyLexicon.Graph.ListViewBasicDefinition?

		/// Indicates whether the authed user has been blocked by the account requested. Optional.
		public let isBlocked: Bool?

		/// A URI which indicates the authed user is blocking the account requested.
		public let blockingURI: String?

		/// An array of the subject account's lists.
		//		public let blockingByArray: AppBskyLexicon.Graph.ListViewBasicDefinition?

		/// A URI which indicates the authed user is following the account requested.
		public let followingURI: String?

		/// A URI which indicates the authed user is being followed by the account requested.
		public let followedByURI: String?

		/// An array of mutual followers. Optional.
		///
		/// - Note: According to the AT Protocol specifications: "The subject's followers whom you
		/// also follow."
		//		public let knownFollowers: KnownFollowers?

		enum CodingKeys: String, CodingKey {
			case isMuted = "muted"
			//			case mutedByArray = "mutedByList"
			case isBlocked = "blockedBy"
			case blockingURI = "blocking"
			//			case blockingByArray = "blockingByList"
			case followingURI = "following"
			case followedByURI = "followedBy"
			//			case knownFollowers
		}

		public init(
			isMuted: Bool?,
			isBlocked: Bool?,
			blockingURI: String?,
			followingURI: String?,
			followedByURI: String?
		) {
			self.isMuted = isMuted
			self.isBlocked = isBlocked
			self.blockingURI = blockingURI
			self.followingURI = followingURI
			self.followedByURI = followedByURI
		}
	}
}
