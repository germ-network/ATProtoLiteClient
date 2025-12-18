//
//  ATProtoLiteClientTests.swift
//  ATProtoLiteClient
//
//  Created by Anna Mistele on 1/31/25.
//

import ATResolve
import Foundation
import OAuthenticator
import Testing

@testable import ATProtoLiteClient

struct SessionTest {

	@Test func testOAuthenticator() async throws {
		//        let responseProvider = URLSession.defaultProvider
		//        let clientMetadataEndpoint = ATProtoOAuthConstants.clientId
		//
		//        let clientConfig = try await ClientMetadata.load(
		//            for: clientMetadataEndpoint, provider: responseProvider)
		//
		//        print(clientConfig)
		//        let serverConfig = try await ServerMetadata.load(
		//            for: ATProtoOAuthConstants.baseHost,
		//            provider: responseProvider
		//        )
		//        print(serverConfig)
		//
		//        let jwtGenerator = BskyDPoP.dpopSigner
		//
		//        let tokenHandling = ATProto.tokenHandling(
		//            account: "dev-mitosis",
		//            server: serverConfig,
		//            jwtGenerator: jwtGenerator
		//        )
		//
		//        let config = Authenticator.Configuration(
		//            appCredentials: clientConfig.credentials,
		//            loginStorage: nil,
		//            tokenHandling: tokenHandling
		//        )
		//
		//        let authenticator = Authenticator(config: config)

	}

	@Test func testDidFetch() async throws {
		let testDid = "did:plc:vun3cp6qs2i74jfbfeld3l2j"

		let result = try await ATResolver(provider: URLSession.shared).plcDirectoryQuery(
			testDid)
		print("output")
		print(result)
	}
}
