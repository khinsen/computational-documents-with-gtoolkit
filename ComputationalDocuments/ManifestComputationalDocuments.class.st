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
	^ #(#(#(#RGMethodDefinition #(#APWorkflowTest #testInstVarCreation #false)) #'2019-03-01T09:48:22.245401+01:00') #(#(#RGMethodDefinition #(#APWorkflow #fuelAccept: #false)) #'2019-03-06T14:37:06.677235+01:00') #(#(#RGMethodDefinition #(#APWorkflowTest #testInstVarAndScriptCreation #false)) #'2019-03-06T18:49:28.242758+01:00') )
]

{ #category : #'code-critics' }
ManifestComputationalDocuments class >> ruleRBRefersToClassRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#APWorkflow #= #false)) #'2019-03-07T17:24:26.855256+01:00') )
]
