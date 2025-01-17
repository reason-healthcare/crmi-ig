Profile: CanonicalVersionBindableOperation
Id: crmi-canonical-version-bindable-operation
Parent: OperationDefinition
Title: "CRMI Operation Profile: Canonical Version Bindable"
Description: """
Operation where default canonical version(s) can be specified

NOTE: This profile is here for backwards compatibility, see ArtifactVersionBindableOperation profile as a successor.

* `canonicalVersion`: Specifies a version to use for a canonical resource if the artifact referencing the resource does not already specify a version. The format is the same as a canonical URL: `[url]|[version]` - e.g. `http://loinc.org|2.56`
* `checkCanonicalVersion`: Edge Case: Specifies a version to use for a canonical resource. If the artifact referencing the resource specifies a different version, an error is returned instead of the package. The format is the same as a canonical URL: `[url]|[version]` - e.g. `http://loinc.org|2.56`
* `forceCanonicalVersion`: Edge Case: Specifies a version to use for a canonical resource. This parameter overrides any specified version in the artifact (and any artifacts it depends on). The format is the same as a canonical URL: `[system]|[version]` - e.g. `http://loinc.org|2.56`. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly.
"""

* parameter
  * insert SliceOnName

* parameter contains canonicalVersion 0..* MS
* parameter[canonicalVersion]
  * name = #canonicalVersion (exactly)
  * min = 0
  * max = "*"
  * use = #in
  * type = #uri

* parameter contains checkCanonicalVersion 0..* MS
* parameter[checkCanonicalVersion]
  * name = #checkCanonicalVersion (exactly)
  * min = 0
  * max = "*"
  * use = #in
  * type = #uri

* parameter contains forceCanonicalVersion 0..* MS
* parameter[forceCanonicalVersion]
  * name = #forceCanonicalVersion (exactly)
  * min = 0
  * max = "*"
  * use = #in
  * type = #uri
