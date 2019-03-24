Class {
	#name : #APScriptWorkflowTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APScriptWorkflowTest >> testAssignDataset [
	| w s |
	w := APScriptWorkflow name: #bar.
	w class addInstVarNamed: #foo.
	s := w addScript: 'foo := 42'.
	s evaluate.
	self assert: w foo equals: 42
]
