//
//  RepoUploadBlob.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 4/16/25.
//  Created by Christopher Jr Riley on 5/20/24.
//

import Foundation

extension ComAtprotoLexiconLite {

	/// A request body model for uploading a blob.
	///
	/// - Note: According to the AT Protocol specifications: "Upload a new blob, to be referenced
	/// from a repository record. The blob will be deleted if it is not referenced within a time
	/// window (eg, minutes). Blob restrictions (mimetype, size, etc) are enforced when the
	/// reference is created. Requires auth, implemented by PDS."
	///
	/// - SeeAlso: This is based on the [`com.atproto.repo.uploadBlob`][github] lexicon.
	///
	/// [github]: https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/uploadBlob.json
	public struct UploadBlobRequestBody: Sendable, Codable {}

	/// A data model for a definition of an output of uploading a blob.
	public struct UploadBlobOutput: Sendable, Codable, Equatable, Hashable {

		/// The type of blob.
		public let type: String?

		/// The strong reference of the blob.
		public let reference: ComAtprotoLexiconLite.BlobReference

		/// The the MIME type.
		///
		/// This can be a `.jpg`, `.png`, and `.gif`.
		public let mimeType: String

		/// The size of the blob.
		public let size: Int

		enum CodingKeys: String, CodingKey {
			case type = "$type"
			case reference = "ref"
			case mimeType
			case size
		}
	}

	/// A data model for a blob reference definition.
	public struct BlobReference: Sendable, Codable, Equatable, Hashable {

		/// The link of the blob reference.
		public let link: String

		enum CodingKeys: String, CodingKey {
			case link = "$link"
		}
	}
}
