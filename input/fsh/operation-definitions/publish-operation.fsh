Instance: crmi-publish
InstanceOf: OperationDefinition
Usage: #definition
* name = "CRMIPublish"
* title = "CRMI Publish Operation"
* status = #active
* kind = #operation
* description = """
The CRMI publish operation processes a publishable bundle containing artifacts and their metadata.

This operation is based on the core FHIR Bundle operation but requires that the
input Bundle conforms to the CRMIPublishableBundle profile. The bundle must be
of type 'transaction' and must contain an ImplementationGuide resource as the
first entry.

The operation enables atomic publication of related artifacts (such as
Libraries, ActivityDefinitions, PlanDefinitions, Measures, etc.) along with
their governing ImplementationGuide, ensuring consistent deployment and proper
metadata management.
"""
* jurisdiction = http://unstats.un.org/unsd/methods/m49/m49.htm#001
* affectsState = true
* code = #publish
* comment = """
The CRMI publish operation processes artifact bundles atomically,
ensuring that all resources in the bundle are published together or the entire
operation fails. This maintains the integrity of artifact packages and
their dependencies.

The operation validates that:
1. The bundle conforms to CRMIPublishableBundle profile
2. The first entry contains an ImplementationGuide
3. All bundle entries have proper transaction requests
4. Referenced resources within the bundle are consistent

"""

// System-level operation
* system = true
* type = false
* instance = false

// Input Parameters
* parameter[0].name = #bundle
* parameter[0].use = #in
* parameter[0].min = 1
* parameter[0].max = "1"
* parameter[0].documentation = """
The publishable bundle to be processed. The bundle must conform to the CRMIPublishableBundle profile, meaning:
- Bundle type must be 'transaction'
- First entry must contain an ImplementationGuide resource
- All entries must have proper transaction request information

The bundle contains all related artifacts that should be published as an atomic unit.
"""
* parameter[0].type = #Bundle
* parameter[0].targetProfile = "http://hl7.org/fhir/uv/crmi/StructureDefinition/crmi-publishable-bundle"

// Output Parameters
* parameter[1].name = #return
* parameter[1].use = #out
* parameter[1].min = 1
* parameter[1].max = "1"
* parameter[1].documentation = """
The bundle transaction response containing the results of processing each entry in the input bundle.

Each entry in the response bundle corresponds to an entry in the input bundle and contains:
- The HTTP status code for the transaction
- The location of the created/updated resource (if successful)
- Any operation outcomes or error messages

The response follows the same structure as the core FHIR Bundle transaction response.
"""
* parameter[1].type = #Bundle
