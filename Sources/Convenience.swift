//
//  Convenience.swift
//  ATProtoLiteClient
//
//  Created by Mark @ Germ on 12/23/25.
//


extension Optional {
	var tryUnwrap: Wrapped {
		get throws {
			guard let self else {
				throw ATProtoClientError.missingOptional("\(Wrapped.self)")
			}
			return self
		}
	}
}
