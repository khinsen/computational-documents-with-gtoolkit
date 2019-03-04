"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestComputationalDocuments,
	#superclass : #PackageManifest,
	#category : #'ComputationalDocuments-Manifest'
}

{ #category : #'code-critics' }
ManifestComputationalDocuments class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#APWorkflowTest #testInstVarCreation #false)) #'2019-03-01T09:48:22.245401+01:00') )
]
