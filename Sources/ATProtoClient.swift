//
//  ATProtoClient.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/22/25.
//

import Foundation
import OAuthenticator

public struct ATProtoClient: ATProtoInterface {
	public func loadServerMetadata(
		for host: String,
		provider: @Sendable (URLRequest) async throws -> (Data, URLResponse)
	) async throws -> ServerMetadata {
		try await .load(for: host, provider: provider)
	}
}
