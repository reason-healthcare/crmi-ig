{::options toc_levels="1..6"/}
{:toc}

{: #artifact-testing}

### Testing Artifacts
{: #testing-artifacts}

Test artifacts are FHIR resources that describe expected behavior for knowledge artifacts, providing a way to verify that an artifact performs as intended across different implementations and environments. Each test case specifies the artifact and operation under test, the input data and parameters, and the expected outputs or outcomes.

Test cases in this implementation guide are represented using the FHIR Library resource with a type of `test-case`. The Library resource provides a flexible container for all the metadata and content elements needed to fully describe a test scenario, including references to the artifact under test, the operation being invoked, the input data bundle, and the expected results.

By capturing test cases as FHIR resources, they can be versioned, packaged, and distributed alongside the knowledge artifacts they test — enabling automated validation, regression testing, and conformance verification throughout the artifact lifecycle.

#### Test Case Structure

* Metadata
* Artifact Under Test
* Operation Under Test
* Input Parameters
* Input Data
* Expected Output Parameters
* Expected Outcome
* Expected Data

Library
* type: test-case
* cqf-testArtifact: Artifact Under Test
* cqf-testArtifact: Operation Under Test
* cqf-inputParameters: input parameters
* cqf-inputData: input data
* cqf-outputParameters: expected output parameters
* cqf-messages: expected outcome
* cqf-outputData: expected data

> NOTE: The `cqf-testArtifact` extension may appear multiple times in a test case Library — once to reference the artifact under test, and once to reference the specific operation being tested.
