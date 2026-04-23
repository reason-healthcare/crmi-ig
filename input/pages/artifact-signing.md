{::options toc_levels="1..6"/}
{:toc}

{: #artifact-signing}

## Overview

Digital signatures provide cryptographic proof of authenticity, integrity, and non-repudiation for FHIR knowledge artifacts. This page describes how CRMI knowledge artifacts align with the [FHIR Digital Signatures specification](https://build.fhir.org/signatures.html) and addresses specific considerations for canonical resource management.

### Use Case: Protecting Intellectual Property and License Compliance

**Background**

Healthcare organizations frequently implement clinical decision support (CDS) rules, guidelines, measures, and assessments that are developed by third-party organizations, academic institutions, or commercial vendors. These knowledge artifacts often contain proprietary algorithms, evidence-based recommendations, or specialized clinical content that is protected by copyright and distributed under specific licensing terms.

**Scenario**

A large healthcare system is implementing a comprehensive sepsis detection and management protocol developed by a renowned medical research institution. The protocol includes:

- Evidence-based clinical decision rules
- Risk stratification algorithms
- Treatment recommendation pathways
- Quality measures and performance indicators

The research institution distributes it under a specific license that:
- Allows use in clinical care settings
- Requires attribution to the original authors
- Prohibits commercial redistribution without permission
- Requires reporting of implementation outcomes back to the institution

**The Problem**

Without proper artifact signing and integrity verification:

- **Unauthorized Modifications**: The healthcare system's IT team might inadvertently or intentionally modify the protocol, potentially invalidating the evidence base and violating license terms.
- **Attribution Loss**: Original authorship and licensing information could be stripped away or corrupted.
- **Version Confusion**: Multiple versions might circulate, making it unclear which version is authentic.
- **Compliance Auditing**: Organizations cannot definitively prove they are using the authentic, unmodified version.

**The Solution: Digital Signing**

By digitally signing artifacts, institutions can:

- **Ensure Integrity**: Verify that content hasn't been tampered with since signing
- **Preserve Attribution**: Maintain metadata about authors, copyright holders, and licensing terms
- **Enable Compliance**: Demonstrate use of authentic, unmodified versions
- **Track Provenance**: Create an immutable record of the artifact's origin

## FHIR Digital Signatures Specification

This implementation guide follows the [FHIR Digital Signatures specification](https://build.fhir.org/signatures.html) (R6 Ballot), which defines:

- **Canonicalization methods** for JSON and XML representations
- **Signature formats** including JWS (JSON Web Signatures) and XML Digital Signatures
- **Detached signatures** carried in Provenance resources
- **Signature verification** requirements for interoperability

### Key Principles

1. **Detached Signatures**: Both JWS and XML signatures MUST be detached (the signed content is separate from the signature itself)
2. **Provenance-Based**: Signatures are carried in Provenance resources, either:
   - Embedded within the signed Bundle/resource structure, or
   - Referenced externally via custom headers or linking mechanisms
3. **Canonicalization**: Content must be canonicalized consistently to ensure signature verification across systems
4. **Certificate Verification**: The signing certificate must be verified against a trusted certificate authority

## Clarifications on FHIR Digital Signatures

### Signature Attachment Methods

The FHIR specification describes several methods for associating signatures with signed content:

#### 1. Embedded Signatures in Bundles

For Document Bundles, signatures are commonly embedded within the Bundle structure:

- A Provenance resource is included as an entry in the Bundle
- The `Provenance.target` references **exactly** `Bundle/[id]` (where `[id]` is the Bundle's `id` value) to indicate it signs the Bundle
- The `Provenance.signature` element contains the detached signature of the Bundle **with all Provenance entries that themselves contain embedded signatures removed** from the entry list before canonicalization (i.e., remove entries whose resource is a Provenance with a `target` referencing `Bundle/[id]`)
- This creates a self-contained signed document

**Clarification**: While the signature data itself is "detached" (the payload is omitted from the JWS/XML signature), the Provenance resource carrying the signature is "embedded" within the Bundle structure. This is the recommended approach for signing Bundles.

> **Note**: The `Bundle.signature` element is **deprecated** in the FHIR specification. Applications SHALL use the Provenance-embedded approach described above.

#### 2. External Provenance References

For non-Bundle resources or when signatures need to be managed separately:

- The Provenance resource is stored separately from the signed resource
- The signed resource can reference the Provenance using:
  - **X-Provenance header** (custom header, currently used): `X-Provenance: [provenance-url]`
  - **Link header** (proposed for improved interoperability): `Link: <[provenance-url]>; rel="provenance"`

**Recommendation**: To improve interoperability and align with web standards, implementers SHOULD support the standard `Link` header as an alternative to or in addition to the custom `X-Provenance` header.

### Canonicalization Variants

The FHIR specification defines several canonicalization methods to balance security and practicality:

| Canonicalization | Description | Use Case |
|------------------|-------------|----------|
| `http://hl7.org/fhir/canonicalization/json` | Full resource (RFC 8785) | Maximum integrity verification |
| `http://hl7.org/fhir/canonicalization/json-xml` | JSON canonicalization with XHTML pre-canonicalized per XML rules | Use when the resource lifecycle may include XML representation |
| `http://hl7.org/fhir/canonicalization/json#data` | Excludes `Resource.text` | Signs structured data only |
| `http://hl7.org/fhir/canonicalization/json#static` | Excludes `Resource.text` and `Resource.meta` | Allows resource mobility across servers |
| `http://hl7.org/fhir/canonicalization/json#narrative` | Only `Resource.id` and `Resource.text` | Human attestation of narrative |
| `http://hl7.org/fhir/canonicalization/json#document` | Omits `Bundle.id` and `Bundle.metadata` | Signing Document Bundles that may be copied across servers |

For CRMI knowledge artifacts, the `#static` variant is recommended as it excludes metadata that changes during resource management while preserving the substantive content. When signing Document Bundle artifacts that may be distributed across servers, the `#document` variant should be considered. If the artifact may ever be represented as XML, use the `json-xml` canonicalization instead of plain `json`.

> **Note on XML canonicalization**: The FHIR specification also defines an XML canonicalization method (`http://hl7.org/fhir/canonicalization/xml`, based on Canonical XML 1.1) for resources represented as XML. See [FHIR Digital Signatures §6.1.2.2.3](https://build.fhir.org/signatures.html#xml) for details. CRMI primarily profiles JWS/JSON signatures, but implementations MAY use XML Digital Signatures following the rules in [§6.1.2.2.7](https://build.fhir.org/signatures.html#DigSig).

### Signing Multiple Resources

A single Provenance resource may sign multiple CRMI artifacts by listing them all in `Provenance.target`. When computing the JWS signature over multiple target resources, the canonicalized resources are placed in a JSON Array in the same order as `Provenance.target`, and the array itself is canonicalized per RFC 8785. This allows, for example, a Library and its dependent ValueSets to be signed together with a single Provenance.

## Implementation Guidance

### Signing CRMI Knowledge Artifacts

*Implementer note: The code shown throughout this page is pseudo-code and intended to be informative.*

A CRMI Knowledge Artifact Server that supports signing will need to implement:

1. **JWKS support** ([RFC 7517](https://datatracker.ietf.org/doc/html/rfc7517)) with a `/.well-known/jwks.json` endpoint to expose public signing keys
2. **The artifact signing process**, which involves the following steps:

#### Step 1: Canonicalize the Resource
{: #implementation-1 }

Canonicalize the resource according to the chosen canonicalization method. For CRMI artifacts using the `#static` variant:

```javascript
// Create a copy and exclude meta and text elements
let resourceCopy = deepCopy(resource)
delete resourceCopy.text  
delete resourceCopy.meta

// Canonicalize according to RFC 8785 (JSON Canonicalization Scheme)
let canonicalJson = canonicalizeJson(resourceCopy)
```

#### Step 2: Create the Signature

Create a JWS detached signature:

```javascript
// The payload is the canonicalized resource
let payload = base64url(canonicalJson)

// Create JWS with detached payload (payload is omitted from the JWS)
let jws = createJWS({
  protectedHeader: {
    alg: 'RS256',
    typ: 'JOSE',
    sigT: new Date().toISOString(),
    canon: 'http://hl7.org/fhir/canonicalization/json#static',
    x5c: [certificateChain], // or use 'kid' for key reference
    srCms: [{
      commId: {
        id: 'urn:oid:1.2.840.10065.1.12.1.1',
        desc: "Author's Signature"
      }
    }]
  },
  payload: payload, // This is used for signing but omitted from output
  privateKey: signingKey
})

// Result is: base64url(header) + ".." + base64url(signature)
// Note the empty payload section
```

> **Note on purpose of signature**: Per FHIR §6.1.2.2.6, the `srCms` signer commitments property in the JWS protected header (shown above) satisfies the SHALL requirement to include the purpose of signature. When the signature is carried in a Provenance resource, `Signature.type`, `Signature.when`, and `Signature.who` SHOULD NOT be set (see §6.1.2.2.8), as those values are already expressed in `Provenance.agent.type`, `Provenance.occurredDateTime`, and `Provenance.agent.who`.

#### Step 3: Create Provenance Resource

Create a Provenance resource to carry the signature:

```json
{
  "resourceType": "Provenance",
  "id": "example-signature",
  "target": [{
    "reference": "ActivityDefinition/example"
  }],
  "occurredDateTime": "2025-10-21T10:00:00Z",
  "recorded": "2025-10-21T10:00:00Z",
  "agent": [{
    "type": {
      "coding": [{
        "system": "urn:iso-astm:E1762-95:2013",
        "code": "1.2.840.10065.1.12.1.1",
        "display": "Author's Signature"
      }]
    },
    "who": {
      "identifier": {
        "system": "http://example.org/certificates",
        "value": "CN=Example Authority"
      }
    }
  }],
  "signature": [{
    "targetFormat": "application/fhir+json;canonicalization=http://hl7.org/fhir/canonicalization/json#static",
    "sigFormat": "application/jose",
    "data": "[base64-encoded-jws]"
  }]
}
```

#### Step 4: Associate Provenance with Resource

**For Bundles:**
Include the Provenance resource as an entry in the Bundle.

**For individual resources:**
Reference the Provenance using headers. Servers SHOULD include both the standard `Link` header and the `X-Provenance` header for maximum client compatibility:

```
Link: <https://example.org/fhir/Provenance/example-signature>; rel="provenance"
X-Provenance: https://example.org/fhir/Provenance/example-signature
```

### Signature Verification

A client verifying a signed FHIR knowledge artifact should:

#### Step 1: Locate the Provenance Resource

- For Bundles: Find Provenance entries with `target` referencing `Bundle/[id]`
- For individual resources: Follow `Link` or `X-Provenance` headers

#### Step 2: Extract Signature Data

```javascript
let signature = provenance.signature[0]
let jwsData = signature.data // base64-encoded JWS
let targetFormat = signature.targetFormat
let canonicalization = extractCanonicalization(targetFormat)
```

#### Step 3: Reconstruct the Canonicalized Resource

```javascript
// Apply the same canonicalization used during signing
let resourceCopy = deepCopy(resource)

if (canonicalization.includes('#static')) {
  delete resourceCopy.text
  delete resourceCopy.meta
} else if (canonicalization.includes('#data')) {
  delete resourceCopy.text
}

let canonicalJson = canonicalizeJson(resourceCopy)
let payload = base64url(canonicalJson)
```

#### Step 4: Verify the JWS Signature

```javascript
// Parse the JWS
let [headerB64, , signatureB64] = jwsData.split('.')
let header = JSON.parse(base64urlDecode(headerB64))

// Retrieve the public key
let publicKey = await getPublicKey(header) // from x5c or kid

// Reconstruct and verify
let signatureInput = headerB64 + '.' + payload
let isValid = verifySignature(signatureInput, signatureB64, publicKey, header.alg)

if (!isValid) {
  throw new Error("Signature verification failed")
}
```

#### Step 5: Verify the Certificate

```javascript
// Verify the certificate chain against a trusted CA
let certificate = parseCertificate(header.x5c[0])
let isTrusted = verifyCertificateChain(certificate, trustedCAs)

if (!isTrusted) {
  throw new Error("Certificate verification failed")
}
```

A successful validation confirms:
- **Authenticity**: The artifact was signed by the claimed authority
- **Integrity**: The content has not been modified since signing
- **Non-repudiation**: The signature provides cryptographic proof of origin

## Worked Example: Non-Bundle Resource

This example demonstrates signing an individual ActivityDefinition resource with an externally referenced Provenance resource.

### Unsigned Resource

```json
{
  "resourceType": "ActivityDefinition",
  "id": "example-activity",
  "url": "http://example.org/ActivityDefinition/example-activity",
  "version": "1.0.0",
  "status": "active",
  "description": "Example activity definition",
  "kind": "Task"
}
```

### Signed Resource Response

When retrieved, the resource includes both `Link` and `X-Provenance` headers:

```
HTTP/1.1 200 OK
Content-Type: application/fhir+json
Link: <https://example.org/fhir/Provenance/activity-signature>; rel="provenance"
X-Provenance: https://example.org/fhir/Provenance/activity-signature

{
  "resourceType": "ActivityDefinition",
  "id": "example-activity",
  "url": "http://example.org/ActivityDefinition/example-activity",
  "version": "1.0.0",
  "status": "active",
  "description": "Example activity definition",
  "kind": "Task"
}
```

### Provenance Resource

Retrieved from `https://example.org/fhir/Provenance/activity-signature`:

```json
{
  "resourceType": "Provenance",
  "id": "activity-signature",
  "target": [{
    "reference": "ActivityDefinition/example-activity"
  }],
  "occurredDateTime": "2025-10-21T10:00:00Z",
  "recorded": "2025-10-21T10:00:00Z",
  "agent": [{
    "type": {
      "coding": [{
        "system": "urn:iso-astm:E1762-95:2013",
        "code": "1.2.840.10065.1.12.1.1"
      }]
    },
    "who": {
      "display": "Example CRMI Server",
      "identifier": {
        "system": "http://example.org/certificates",
        "value": "CN=crmi.example.org"
      }
    }
  }],
  "signature": [{
    "targetFormat": "application/fhir+json;canonicalization=http://hl7.org/fhir/canonicalization/json#static",
    "sigFormat": "application/jose",
    "data": "eyJ0eXAiOiJKT1NFIiwiYWxnIjoiUlMyNTYiLCJzaWdUIjoiMjAyNS0xMC0yMVQxMDowMDowMFoiLCJjYW5vbiI6Imh0dHA6Ly9obDcub3JnL2ZoaXIvY2Fub25pY2FsaXphdGlvbi9qc29uI3N0YXRpYyJ9..dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
  }]
}
```

This approach allows:
- The signature to be managed independently of the resource
- Multiple signatures to be associated with a single resource
- Signature verification without modifying the original resource
- Standard HTTP header semantics for discovery

## Additional Considerations

### Long-Term Signatures

For signatures that must remain valid over extended periods:

- Use **JAdES-B-LTA** (JSON) or **XAdES-X-L** (XML) profiles
- Include timestamping to prove signature creation time
- Include certificate revocation status
- Archive signing certificates for later verification

### Signature Rotation

When signing keys are rotated:

- Maintain multiple valid signatures with different keys
- Include timestamp information to establish signature order
- Preserve older signatures for auditability
- Update documentation about active signing keys

### Performance Considerations

- Cache JWKS endpoints to reduce network calls
- Pre-validate certificates before signature operations
- Consider batch signing for multiple resources
- Use appropriate canonicalization to minimize signature breakage

## References

- [FHIR Digital Signatures](https://build.fhir.org/signatures.html) (R6 Ballot)
- [RFC 7515: JSON Web Signature (JWS)](https://tools.ietf.org/html/rfc7515)
- [RFC 8785: JSON Canonicalization Scheme (JCS)](https://www.rfc-editor.org/rfc/rfc8785)
- [RFC 7517: JSON Web Key (JWK)](https://datatracker.ietf.org/doc/html/rfc7517)
- [XML Signature Syntax and Processing Version 1.1](https://www.w3.org/TR/xmldsig-core/)
- [ETSI TS 119 182-1: JAdES](https://www.etsi.org/deliver/etsi_ts/119100_119199/11918201/01.01.01_60/ts_11918201v010101p.pdf)
- [W3C XAdES](https://www.w3.org/TR/XAdES/)