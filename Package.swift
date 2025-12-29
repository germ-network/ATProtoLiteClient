// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ATProtoLiteClient",
	platforms: [.iOS(.v17), .macOS(.v14)],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "ATProtoLiteClient",
			targets: ["ATProtoLiteClient"])
	],
	dependencies: [
		.package(
			url: "https://github.com/germ-network/autonomous-comm-protocol.git",
			from: "1.1.4"
		),
		.package(
			url: "https://github.com/germ-network/OAuthenticator",
			exact: "0.7.1"
		),
		.package(
			url: "https://github.com/germ-network/ATResolve",
			exact: "1.1.1"
		),
		.package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "ATProtoLiteClient",
			dependencies: [
				.product(name: "CommProtocol", package: "autonomous-comm-protocol"),
				.product(name: "OAuthenticator", package: "OAuthenticator"),
				.product(name: "ATResolve", package: "ATResolve"),
			],
		),
		.testTarget(
			name: "ATProtoLiteClientTests",
			dependencies: ["ATProtoLiteClient"]
		),
		.testTarget(
			name: "JWTTests",
			dependencies: [
				"ATProtoLiteClient", .product(name: "JWTKit", package: "jwt-kit"),
			]
		),
	]
)
