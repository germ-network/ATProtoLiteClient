//
//  Test.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 4/25/25.
//

import ATProtoLiteClient
import CryptoKit
import Foundation
import JWTKit
import Testing

struct TestPayload: Encodable, JWTPayload {
	let status: Int
	let message: String

	func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
		guard self.status == 200 else {
			throw JWTLexiconLite.JWTError.notImplemented
		}
	}
}

struct JWTTest {

	@Test func testJWT() async throws {
		let dpopKey = P256.Signing.PrivateKey()
		let payload = TestPayload(status: 200, message: "Success!")

		// Generate the JWT with our library
		let jwt = try await JWTSerializerLite.sign(
			payload,
			with: JWTLexiconLite.JWTHeader(
				typ: "dpop+jwt",
				jwk: JWTLexiconLite.JWK(key: dpopKey)
			),
			using: ECDSASigner(key: dpopKey)
		)

		// Verify the JWT with JWTKit
		let key = try ECDSA.PrivateKey<P256>(pem: dpopKey.pemRepresentation)
		let keys = await JWTKeyCollection().add(ecdsa: key)
		let verifiedPayload: TestPayload = try await keys.verify(jwt)
		#expect(verifiedPayload.status == payload.status)
		#expect(verifiedPayload.message == payload.message)
	}

}
