Invariant:   crmi-artifact-operation-1
Description: "Parameter url type is uri or canonical"
Expression:  "type='uri' or type='canonical'"
Severity:    #error

Profile: ArtifactOperation
Id: crmi-artifact-operation
Parent: OperationDefinition
Title: "CRMI Operation Profile: Artifact Operation"
Description: """
Profile for artifact operations.

This establishes input parameters when the operation is invoked at the resource
type level. The parameters are used to identify or specify the resource for the
operation.

* `url`: artifact canonical&ast; for the resource as a canonical reference (with or without a version) (or uri for non-canonical resources)
* `resource`: instance of a canonical resource

&ast;The artifact URL for canonical resources is `.url`, for non-canonical resources, it is
the extension `artifact-url`. The version for canonical resources is `.version`, for non-canonical
resources it is the extension `artifact-version`.

NOTE: When invoking canonical operations using a `url`, if the reference is versionless, the latest known version of the resource should be used, as specified in the [Artifact Versioning](artifact-lifecycle.html#artifact-versioning) discussion.

NOTE: This pattern can be applied for operations that are invoked on one or more resources.
"""

* parameter
  * insert SliceOnName

* parameter contains url 0..* MS
* parameter[url]
  * name = #url (exactly)
  * use = #in
  * min = 0
  * max = "1"
  * obeys crmi-artifact-operation-1

* parameter contains resource 0..* MS
* parameter[resource]
  * name = #resource (exactly)
  * use = #in
  * min = 0
  * max = "1"
  * type from ArtifactResourceTypes (required)
