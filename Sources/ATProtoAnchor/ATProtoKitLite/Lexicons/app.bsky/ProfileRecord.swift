//
//  ProfileRecord.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  From the AppBskyActorProfile file by Christopher Jr Riley created 5/17/24.
//

import Foundation

extension AppBskyLexiconLite {

	/// The main data model definition for an actor.
	///
	/// - Note: According to the AT Protocol specifications: "A declaration of a Bluesky
	/// account profile."
	///
	/// - SeeAlso: This is based on the [`app.bsky.actor.profile`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/actor/profile.json
	public struct ProfileRecord: ATRecordProtocolLite, Sendable {

		/// The identifier of the lexicon.
		///
		/// - Warning: The value must not change.
		public static let type: String = "app.bsky.actor.profile"

		/// The display name of the profile. Optional.
		///
		/// - Important: Current maximum length is 64 characters.
		public let displayName: String?

		/// The description of the profile. Optional.
		///
		/// - Important: Current maximum length is 256 characters.
		///
		/// - Note: According to the AT Protocol specifications: "Free-form profile
		/// description text."
		public let description: String?

		/// The avatar image URL of the profile. Optional.
		///
		/// - Note: Only JPEGs and PNGs are accepted.
		///
		/// - Important: Current maximum file size 1,000,000 bytes (1 MB).
		///
		/// - Note: According to the AT Protocol specifications: "Small image to be displayed next
		/// to posts from account. AKA, 'profile picture'"
		public let avatarBlob: ComAtprotoLexiconLite.UploadBlobOutput?

		/// The banner image URL of the profile. Optional.
		///
		/// - Note: Only JPEGs and PNGs are accepted.
		///
		/// - Important: Current maximum file size 1,000,000 bytes (1 MB).
		///
		/// - Note: According to the AT Protocol specifications: "Larger horizontal image to
		/// display behind profile view."
		public let bannerBlob: ComAtprotoLexiconLite.UploadBlobOutput?

		/// An array of user-defined labels. Optional.
		///
		/// - Note: According to the AT Protocol specifications: "Self-label values, specific to
		/// the Bluesky application, on the overall account."
		public let labels: ComAtprotoLexiconLite.SelfLabelsDefinition?

		/// The starter pack the user account used to join Bluesky. Optional.
		public let joinedViaStarterPack: ComAtprotoLexiconLite.StrongReference?

		/// A post record that's pinned to the profile. Optional.
		public let pinnedPost: ComAtprotoLexiconLite.StrongReference?

		/// The date and time the profile was created. Optional.
		public let createdAt: Date?

		public init(
			displayName: String? = nil, description: String? = nil,
			avatarBlob: ComAtprotoLexiconLite.UploadBlobOutput? = nil,
			bannerBlob: ComAtprotoLexiconLite.UploadBlobOutput? = nil,
			labels: ComAtprotoLexiconLite.SelfLabelsDefinition? = nil,
			joinedViaStarterPack: ComAtprotoLexiconLite.StrongReference? = nil,
			pinnedPost: ComAtprotoLexiconLite.StrongReference? = nil,
			createdAt: Date? = nil
		) {
			self.displayName = displayName
			self.description = description
			self.avatarBlob = avatarBlob
			self.bannerBlob = bannerBlob
			self.labels = labels
			self.joinedViaStarterPack = joinedViaStarterPack
			self.pinnedPost = pinnedPost
			self.createdAt = createdAt
		}
	}
}

extension AppBskyLexiconLite.ProfileRecord: Codable {

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
		self.description = try container.decodeIfPresent(String.self, forKey: .description)
		self.avatarBlob = try container.decodeIfPresent(
			ComAtprotoLexiconLite.UploadBlobOutput.self, forKey: .avatarBlob)
		self.bannerBlob = try container.decodeIfPresent(
			ComAtprotoLexiconLite.UploadBlobOutput.self, forKey: .bannerBlob)
		self.labels = try container.decodeIfPresent(
			ComAtprotoLexiconLite.SelfLabelsDefinition.self, forKey: .labels)
		self.joinedViaStarterPack = try container.decodeIfPresent(
			ComAtprotoLexiconLite.StrongReference.self, forKey: .joinedViaStarterPack)
		self.pinnedPost = try container.decodeIfPresent(
			ComAtprotoLexiconLite.StrongReference.self, forKey: .pinnedPost)
		self.createdAt = try container.decodeDateIfPresentLite(forKey: .createdAt)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encodeIfPresent(self.displayName, forKey: .displayName)
		try container.encodeIfPresent(self.description, forKey: .description)
		try container.encodeIfPresent(self.avatarBlob, forKey: .avatarBlob)
		try container.encodeIfPresent(self.bannerBlob, forKey: .bannerBlob)
		try container.encodeIfPresent(self.labels, forKey: .labels)
		try container.encodeIfPresent(
			self.joinedViaStarterPack, forKey: .joinedViaStarterPack)
		try container.encodeIfPresent(self.pinnedPost, forKey: .pinnedPost)
		try container.encodeDateIfPresentLite(self.createdAt, forKey: .createdAt)
	}

	enum CodingKeys: String, CodingKey {
		case type = "$type"
		case displayName
		case description
		case avatarBlob = "avatar"
		case bannerBlob = "banner"
		case labels
		case joinedViaStarterPack
		case pinnedPost
		case createdAt
	}
}
