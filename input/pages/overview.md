{: #overview}

The following is a conceptual diagram of various systems and specifications:
<div style="max-width:640px;">
{% include img.html img="CRMI-Overview.png" %}
</div>

* Authoring System: A system enabling and orchestrating content and content modifications.
  * Authoring Backing Roles, including Authoring Knowledge Repository and Authoring Terminology Services
* Packaging: Specifications for packing artifacts for publishing
* Publishing: Specifications for publishing
* Distributing Artifacts: Specifications for artifact distribution

## Authoring System

Authoring systems allow new content to be introduced into a system. At a minimum they provide capabilities to:
* Create new resources
* Create new versions of existing resources
* Package content for publishing

Many authoring systems also:
* Save work-in-progress
* Orchestrate dependencies
* Validate content
* Track changes
* Content version control

An example of an authoring system is Visual Studio Code (with various plugins), git, build tools using IG Publisher, and Sushi. In this case the authoring content could be stored in a filesystem as text files in a git repository. 

An authoring system MAY use an Authoring Knowledge Repository and Authoring Terminology Server to aid in the authoring process, depending on authoring tool requirements.

## Packaging

Packaging artifacts MAY be either FHIR Bundles, or FHIR Packages. See [Packaging](packaging.html) for more.

## Publishing

If the package is a FHIR Bundle, publishing uses the FHIR REST API where transaction bundle(s) are sent to the Knowledge Artifact Repository for processing. **NOTE: Should we separate terminology from non-terminology Bundles?**

```
curl -X POST -d @bundle.json http://knowledge-repository/
```

If the package is a FHIR package, publishing uses the NPM API. The receiving system SHOULD process the request, opening the tarball and create non-terminology resources on the Knowledge Artifact Server, and terminology resources on the Knowledge Terminology Server. This MAY use the same FHIR bundle -based packaging. A benefit of using FHIR packages is to support authoring tools, such as IG Publisher and Sushi, where dependencies are managed with FHIR packages.

```
npm --registry http://knowledge-registry publish output/package.tgz
```

## Distribution

### Uplinks

As commonly found in software package management, uplinks provide local registries virtualized access to artifacts that might externally. This can apply to FHIR Knowledge Artifact Repositories, as shown below:

<div style="max-width:640px;">
{% include img.html img="uplinks.png" %}
</div>

When responding to a distribution request (FHIR REST, NPM, or $package), a Knowledge Artifact Repository MAY attempt to look in report repositories for artifacts.

### Syndication

Similar to uplinks, syndication allows broadcasting of content changes. This mechanism MAY be used by downstream systems, or federated Knowledge Artifact Repositories so preemptive downloading, or notification message send to interested parties. The syndication API SHALL be based on ATOM, an example is shown below:

```xml
<!-- see: https://validator.w3.org/feed/docs/atom.html -->
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:hl7="http://hl7.org/fhir/uv/crmi/syndication">
  <title>HL7 CRMI Knowledge Artifact Server Feed</title>
  <link rel="self" type="application/atom+xml" href="https://crmi-server/syndication/v1/feed.xml" />
  <id>urn:uuid:e39958d4-380e-4252-8707-6afeff8b7911</id>
  <updated>2023-01-01T01:00:00Z</updated>
  <entry>
    <id>urn:uuid:2c466218-337c-3367-95d9-57f65cd1a572</id>
    <title>SomeMeasure Package</title>
    <updated>2020-08-23T23:37:17Z</updated>
    <published>2020-08-23T23:37:17Z</published>
    <hl7:artifactVersion>0.0.0</hl7:artifactVersion>
    <hl7:artifactType>package</hl7:artifactType>
    <hl7:fhirVersion>4.0.1</hl7:fhirVersion>
    <hl7:publishAction>publish</hl7:publishAction>
    <author>
      <name>SomeMeasure Agency</name>
      <uri>http://www.measure.org</uri>
      <email>help@measure.org</email>
    </author>
    <!-- when publishing a new FHIR package, we expose both the package tarball -->
    <link rel="alternate" type="application/fhir+gzip"
      href="https://crmi-server/packages/some.fhir.uv.somemeasure/-/some.fhir.uv.somemeasure-0.0.0.tgz" />
    <!-- also include a Bundle transaction of all resources in the direct package with conditional create url and version -->
    <link rel="alternate" type="application/fhir+json"
      href="https://crmi-server/Bundle/f0099e15-3c06-4905-ba65-86749757fe80" />
    <summary>Contains updates to SomeMeasure, a quality measure you need in your life.</summary>
    <rights>Copyright 2019 SomeMeasure Agency. This content contains information which is protected
      by copyright. All Rights Reserved. No part of this work may be reproduced or used in any form
      or by any means - graphic, electronic, or mechanical, including photocopying, recording,
      taping, or information storage and retrieval systems - without the permission of the
      SomeMeasure Agency.</rights>
  </entry>
  <entry>
    <id>urn:uuid:16d8afdf-79d4-4dfe-87ce-cfc6cd186f62</id>
    <title>ValueSet ABC Removed</title>
    <updated>2020-08-23T23:37:17Z</updated>
    <hl7:fhirVersion>4.0.1</hl7:fhirVersion>
    <hl7:artifactType>resource</hl7:artifactType>
    <hl7:publishAction>unpublish</hl7:publishAction>
    <!-- this is a transaction bundle with a conditional delete using the canonical url and version -->
    <link rel="alternate" type="application/fhir+json; fhirVersion=4.0"
      href="https://crmi-server/Bundle/b8e21acc-a8ee-41d5-acac-b7331d675fbe"/>
  </entry>
  <entry>
    <id>urn:uuid:c4ae3f0f-2aaf-4afc-9752-e5d856b45461</id>
    <title>Update FHIR Library</title>
    <updated>2020-08-23T23:37:17Z</updated>
    <hl7:artifactVersion>0.2.1</hl7:artifactVersion>
    <hl7:artifactType>resource</hl7:artifactType>
    <hl7:fhirVersion>4.0.1</hl7:fhirVersion>
    <hl7:publishAction>publish</hl7:publishAction>
    <!-- this is a transaction bundle with a conditional create using the canonical url and version -->
    <link rel="alternate" type="application/fhir+json; fhirVersion=4.0"
      href="https://crmi-server/Bundle/d654dcde-ba89-4f6e-9024-bced216d58e9"/>
  </entry>
</feed>
```

### FHIR REST API

Knowledge Artifacts, including terminology MAY be distributed through the standard FHIR read and search APIs.

### NPM (FHIR Package)

If content is published using a FHIR package, than is SHALL be installable using the NPM API. The primary use-case is to support authoring tools that use FHIR packages for dependency management.

### FHIR $package Operation

Regardless how the content was published, the `$package` operation allows for targeted retrieval of content. This results in a FHIR Bundle of artifacts where all dependencies MAY be included depending on the operation parameters. `$package` does not consider boundaries of a FHIR Package or IG.

Since the `$package` operation happens on the Knowledge Artifact Server, there is no knowledge of what might have been already distributed to the the downstream system. A second, similar operation `$dependencies` (can `$data-requirements` really do this?) provides all dependency requirements, but not the actual resources. The downstream system could then optimize and download only resources that are missing (using a FHIR Bundle request). For example, consider a very large ValueSet used by several different Measures.

### Dependencies

Both `$package` and `$dependencies` operations are available for all canonical resources:

1. StructureDefinition, StructureMap
2. ValueSet, CodeSystem, NamingSystem, ConceptMap
3. Questionnaire, ActivityDefinition, PlanDefinition, Library, Measure
4. ObservationDefinition, SpecimenDefinition, MedicationKnowledge, etc...

Each resource has required dependencies, as shown in the table below.


#### Dependency Tracing

* **Structure Definition**
  * `baseDefinition`
  * `differential.element[].constraint[].source`
  * `differential.element[].binding.valueSet`
  * `extension[cpg-inferenceExpression].reference`
  * `extension[cpg-assertionExpression].reference`
  * `extension[cpg-featureExpression].reference`
* **Structure Map**
  * `structure[].url`
  * `import[]`
  * `group[].rule[]..source[].defaultValue[x]`
* **ValueSet**
  * `compose.include[].valueSet`
  * `compose.exclude[].valueSet`
* **CodeSystem**
  * `valueSet`
  * `supplements`
* **NamingSystem**
  * `(none)`
* **ConceptMap**
  * `sourceCanonical`
  * `targetCanonical`
  * `group[].element[].target[].dependsOn[].system`
  * `group[].element[].target[].product[]..system`
  * `unmapped.url`
* **Questionnaire**
  * `item[]..definition`
  * `item[]..answerValueSet`
  * `item[]..extension[itemMedia]`
  * `item[]..extension[itemAnswerMedia]`
  * `item[]..extension[unitValueSet]`
  * `item[]..extension[referenceProfile]`
  * `item[]..extension[candidateExpression].reference`
  * `item[]..extension[lookupQuestionnaire]`
  * `extension[cqf-library]`
  * `extension[launchContext]`
  * `extension[variable].reference`
  * `item[]..extension[variable].reference`
  * `item[]..extension[initialExpression].reference`
  * `item[]..extension[calculatedExpression].reference`
  * `item[]..extension[cqf-calculatedValue].reference`
  * `item[]..extension[cqf-expression].reference`
  * `item[]..extension[sdc-questionnaire-subQuestionnaire]`
* **ActivityDefinition**
  * `relatedArtifact[].resource`
  * `library[]`
  * `profile`
  * `location`
  * `productReference`
  * `specimenRequirement[]`
  * `observationRequirement[]`
  * `observationResultRequirement[]`
  * `transform`
  * `extension[cpg-collectWith]`
  * `extension[cpg-enrollIn]`
  * `extension[cpg-reportWith]`
PlanDefinition
  * `relatedArtifact[].resource`
  * `library[]`
  * `action[]..trigger[].dataRequirement[].profile[]`
  * `action[]..trigger[].dataRequirement[].codeFilter[].valueSet`
  * `action[]..condition[].expression.reference`
  * `action[]..input[].profile[]`
  * `action[]..input[].codeFilter[].valueSet`
  * `action[]..output[].profile[]`
  * `action[]..output[].codeFilter[].valueSet`
  * `action[]..definitionCanonical`
  * `action[]..dynamicValue[].expression.reference`
  * `extension[cpg-partOf]`
* **Library**
  * `relatedArtifact[].resource`
  * `dataRequirement[].profile[]`
  * `dataRequirement[].codeFilter[].valueSet`
* **Measure**
  * `relatedArtifact[].resource`
  * `library[]`
  * `group[].population[].criteria.reference`
  * `group[].stratifier[].criteria.reference`
  * `group[].stratifier[].component[].criteria.reference`
  * `supplementalData[].criteria.reference`
  * `extension[cqfm-inputParameters][]`
  * `extension[cqfm-expansionParameters][]`
  * `extension[cqfm-effectiveDataRequirements]`
  * `extension[cqfm-cqlOptions]`
  * `extension[cqfm-component][].resource`
* **GraphDefinition**
  * `extension[cpg-relatedArtifact].reference`
* **ImplementationGuide**
  * `extension[cpg-relatedArtifact].reference`
* **Ingredient**
  * `for`
* **Medication**
  * `manufacturer`
  * `ingredient[].itemReference`
* **Substance**
  * `ingredient[].substanceReference`
* **Parameters**
  * `parameter[].resource`
* **MedicationKnowledge**
  * `relatedMedicationKnowledge[].reference`
  * `monograph[].source`
  * `ingredient[].itemReference`
  * `reglatory[].reglatoryAuthroity`
