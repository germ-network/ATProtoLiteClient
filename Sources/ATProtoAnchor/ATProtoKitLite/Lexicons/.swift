//
//  GetFollowsOutput.swift
//  ATProtoLogin
//
//  Created by Anna Mistele on 6/2/25.
//  Created by Christopher Jr Riley on 2024-05-19.
//

import Foundation

extension AppBskyLexiconLite {

	/// An output model for for grabbing all of the accounts the user account follows.
	///
	/// - Note: According to the AT Protocol specifications: "Enumerates accounts which a specified
	/// account (actor) follows."
	///
	/// - SeeAlso: This is based on the [`app.bsky.graph.getFollows`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/graph/getFollows.json
	public struct GetFollowsOutput: Sendable, Codable {

		/// The user account itself.
		public let subject: AppBskyLexiconLite.ProfileDefinition

		/// The mark used to indicate the starting point for the next set of results. Optional.
		public let cursor: String?

		/// An array of user accounts that the user account follows.
		public let follows: [AppBskyLexiconLite.ProfileDefinition]
	}
}
