//
//  ResolveHandleOutput.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 4/17/25.
//

/// An output model for resolving handles.
///
/// - SeeAlso: This is based on the [`com.atproto.identity.resolveHandle`][github] lexicon.
///
/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/identity/resolveHandle.json
public struct ResolveHandleOutput: Sendable, Decodable {

	/// The resolved handle's decentralized identifier (DID).
	public let did: String
}
