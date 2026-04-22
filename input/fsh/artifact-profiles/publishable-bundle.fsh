/**
NOTE: Sushi does not support multiline Expression! Here is the expression in a readable form:

entry.where(
  resource.is(ActivityDefinition) or 
  resource.is(CapabilityStatement) or 
  resource.is(ChargeItemDefinition) or 
  resource.is(CodeSystem) or 
  resource.is(CompartmentDefinition) or 
  resource.is(ConceptMap) or 
  resource.is(EventDefinition) or 
  resource.is(Evidence) or 
  resource.is(EvidenceVariable) or 
  resource.is(ExampleScenario) or 
  resource.is(GraphDefinition) or 
  resource.is(ImplementationGuide) or 
  resource.is(Library) or 
  resource.is(Measure) or 
  resource.is(MessageDefinition) or 
  resource.is(NamingSystem) or 
  resource.is(OperationDefinition) or 
  resource.is(PlanDefinition) or 
  resource.is(Questionnaire) or 
  resource.is(ResearchDefinition) or 
  resource.is(ResearchElementDefinition) or 
  resource.is(RiskEvidenceSynthesis) or 
  resource.is(SearchParameter) or 
  resource.is(StructureDefinition) or 
  resource.is(StructureMap) or 
  resource.is(TerminologyCapabilities) or 
  resource.is(TestScript) or 
  resource.is(ValueSet)
).all(
  request.ifNoneExist.exists() and 
  request.ifNoneExist.contains('url=') and 
  request.ifNoneExist.contains('version=')
)
*/
Invariant: crmi-bundle-canonical-ifnoneexist
Description: "For canonical resources, Bundle.entry.request must have ifNoneExist parameter based on url and version"
Expression: "entry.where( resource.is(ActivityDefinition) or resource.is(CapabilityStatement) or resource.is(ChargeItemDefinition) or resource.is(CodeSystem) or resource.is(CompartmentDefinition) or resource.is(ConceptMap) or resource.is(EventDefinition) or resource.is(Evidence) or resource.is(EvidenceVariable) or resource.is(ExampleScenario) or resource.is(GraphDefinition) or resource.is(ImplementationGuide) or resource.is(Library) or resource.is(Measure) or resource.is(MessageDefinition) or resource.is(NamingSystem) or resource.is(OperationDefinition) or resource.is(PlanDefinition) or resource.is(Questionnaire) or resource.is(ResearchDefinition) or resource.is(ResearchElementDefinition) or resource.is(RiskEvidenceSynthesis) or resource.is(SearchParameter) or resource.is(StructureDefinition) or resource.is(StructureMap) or resource.is(TerminologyCapabilities) or resource.is(TestScript) or resource.is(ValueSet)).all( request.ifNoneExist.exists() and request.ifNoneExist.contains('url=') and request.ifNoneExist.contains('version='))"
Severity: #error

Invariant: crmi-bundle-first-entry-ig
Description: "The first entry in a PublishableBundle must be an ImplementationGuide resource"
Expression: "entry.first().resource.is(ImplementationGuide)"
Severity: #error

Profile: CRMIPublishableBundle
Parent: Bundle
Id: crmi-publishable-bundle
Title: "CRMI Publishable Bundle"
Description: """
A publishable bundle is a Bundle resource that represents a collection of FHIR
resources that can be published as a cohesive unit. 

The bundle must be of type 'transaction' and must contain an ImplementationGuide
resource as the first entry. This ensures that the bundle represents a complete,
publishable package with proper metadata and resource organization defined by
the implementation guide.

This profile supports the distribution and management of artifacts as
atomic units, enabling consistent publication and deployment of related clinical
decision support resources, quality measures, and other healthcare knowledge
content.
"""

// Using invariant because positional-based slicing is not supported in R4 FHIR --
* obeys crmi-bundle-first-entry-ig
* obeys crmi-bundle-canonical-ifnoneexist

// Bundle must be of type transaction
* type = #transaction

// All entries must have proper transaction requests
* entry.request 1..1
* entry.request ^short = "Transaction request for each bundle entry"
* entry.request.method 1..1
* entry.request.url 1..1
* entry.request.method  = #POST
