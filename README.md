# ATProtoLiteClient

ATProto client with OAuth and selected lexicons for the Germ DM client.

## Credit
This incorporates types from CJ Riley's excellent https://github.com/MasterJ93/ATProtoKit. 
We're unable to directly include it as a dependency as we have strict binary size requirements and we don't need the majority of the ported lexicon.

# Maintenance
## Swift Format
```
swift format . -ri && swift format lint . -r
``` 
referencing `.swift-format`. Also have `.editorconfig` set.

ensure git's `ignoreRevsFile` is set
```
git config --global blame.ignoreRevsFile .git-blame-ignore-revs
```

## Code Scanning
Periphery is configured with .periphery.yml
https://github.com/peripheryapp/periphery

## CI
Configured for github actions
