1. The default behavior for resolving un-versioned canonical references is:
  a. If the referenced artifact is part of the same package as the referring artifact, use the same version; 
  b. otherwise try to resolve the most recent version of the referenced artifact.
2. However, specifying fixed versions of canonicals as runtime configuration is desirable
3. This can be done using a repeating parameter `canonicalVersion` with a value of a fully versioned [canonical reference](http://hl7.org/fhir/references.html#canonical).

NOTE: If content explicitly specifies canonical reference, it prevails.

### General Form
```
${operation}?canonicalVersion={canonical}|{desired-version}(can repeat)
```

### Measure:
```
/Measure/123/$evaluate-measure?
  canonicalVersion=http://loinc.org|2.74&
  canonicalVersion=http://snomed.info/sct|3.1.0
```

### PlanDefinition (specifying a version for an MCode patient profile here):
```
/PlanDefinition/12345/$apply?
  canonicalVersion=http://loinc.org|2.74&
  canonicalVersion=http://snomed.info/sct|3.1.0&
  canonicalVersion=http://hl7.org/fhir/us/mcode/StructureDefinition/mcode-cancer-patient|2.0.0
```

### Packaging a library
```
/Library/12345/$package?
  canonicalVersion=http://loinc.org|2.74&
  capability=executable
```


Also consider an operation (perhaps `dependencies` or `data-requirements`?) that at any point in time can provide the current version(s) of all canonicals. This way a client could remember and specify for future invocations of the operation.
