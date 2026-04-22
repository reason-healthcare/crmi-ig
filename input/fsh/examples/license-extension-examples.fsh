Instance: ExampleLicensedLibrary
InstanceOf: Library
* status = #active
* type = http://terminology.hl7.org/CodeSystem/library-type#logic-library
* description = """
This example demonstrates how licensing information can be attached to FHIR artifacts using CRMI extensions. 

The library shows two properties to artifact licensing:
1. **License Code**: A standardized code (like 'not-open-source') that provides machine-readable license classification
2. **License Detail**: Human-readable markdown text that contains the full license terms, contact information, and usage restrictions

This approach enables both automated license compliance checking through standardized codes and detailed legal clarity through comprehensive license text.
"""
* meta.extension[CRMILicense].valueCode = #not-open-source
* meta.extension[CRMILicenseDetail].valueMarkdown = """
# ACME Corporation's proprietary license for the Example Licensed Library.

This library is licensed under the ACME Corporation's proprietary license, which allows for use in non-commercial projects only. For more details, please refer to the license text at:
[ACME License](https://example.com/acme-license).

This license does not allow redistribution or modification of the library.
For inquiries, contact ACME Corporation at [info@example.com](mailto:info@example.com).
"""
