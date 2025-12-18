//
//  DIDDocument.swift
//  ATProtoLiteClient
//
//  Pulled in by Anna Mistele on 8/21/25.
//  Created as UserSession.swift by Christopher Jr Riley on 1/5/24.
//

import Foundation

/// Represents a DID document in the AT Protocol, containing crucial information fo
/// AT Protocol functionality.
///
/// The DID document includes the decentralized identifier (DID), verification methods, and
/// service endpoints necessary for interacting with the AT Protocol ecosystem, such as
/// authentication and data storage locations.
public struct DIDDocument: Sendable, Codable {

	/// An array of context URLs for the DID document, providing additional semantics for
	/// the properties.
	public var context: [String]

	/// The unique identifier of the DID document.
	public var id: String

	/// An array of URIs under which this decentralized identifier (DID) is also known, including
	/// the primary handle URI. Optional.
	public var alsoKnownAs: [String]?

	/// An array of methods for verifying digital signatures, including the public signing key
	/// for the account.
	public var verificationMethod: [VerificationMethod]

	/// An array of service endpoints related to the decentralized identifier (DID), including the
	/// Personal Data Server's (PDS) location.
	public var service: [ATService]

	/// Checks if the ``service`` property array contains items, and if so, sees if `#atproto_pds`
	/// is in the ``ATService/id`` property.
	///
	/// - Returns: An ``ATService`` item.
	///
	/// - Throws: ``DIDDocumentError`` if ``service`` is empty or if none of the items
	/// contain `#atproto_pds`.
	public func checkServiceForATProto() throws -> ATService {
		let services = self.service

		guard services.count > 0 else {
			throw DIDDocumentError.emptyArray
		}

		for service in services {
			if service.id == "#atproto_pds" {
				return service
			}
		}

		throw DIDDocumentError.noATProtoPDSValue
	}

	enum CodingKeys: String, CodingKey {
		case context = "@context"
		case id
		case alsoKnownAs
		case verificationMethod
		case service
	}

	/// Errors relating to the DID Document.
	public enum DIDDocumentError: Error {

		/// The ``DIDDocument/service`` array is empty.
		case emptyArray

		/// None of the items in the ``DIDDocument/service`` array contains a `#atproto_pds`
		/// value in the ``ATService/id`` property.
		case noATProtoPDSValue
	}
}

/// Describes a method for verifying digital signatures in the AT Protocol, including the public
/// signing key.
public struct VerificationMethod: Sendable, Codable {

	/// The unique identifier of the verification method.
	public var id: String

	/// The type of verification method that indicates the cryptographic curve used.
	public var type: String

	/// The controller of the verification method, which matches the
	/// decentralized identifier (DID).
	public var controller: String

	/// The public key, in multibase encoding; used for verifying digital signatures.
	public var publicKeyMultibase: String
}

/// Represents a service endpoint in a DID document, such as the
/// Personal Data Server's (PDS) location.
public struct ATService: Sendable, Codable {

	/// The unique identifier of the service.
	public var id: String

	/// The type of service (matching `AtprotoPersonalDataServer`) for use in identifying
	/// the Personal Data Server (PDS).
	public var type: String

	/// The endpoint URL for the service, specifying the location of the service.
	public var serviceEndpoint: URL
}
