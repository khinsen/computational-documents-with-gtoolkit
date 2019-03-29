Class {
	#name : #APScriptWorkflowTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APScriptWorkflowTest >> testAssignDataset [
	| w |
	w := APScriptWorkflow name: #bar.
	w class addInstVarNamed: #foo.
	(w apValueHolderFor: #foo) value: 42.
	self assert: w foo equals: 42
]

{ #category : #tests }
APScriptWorkflowTest >> testAssignDatasetInScript [
	| w s |
	w := APScriptWorkflow name: #bar.
	w class addInstVarNamed: #foo.
	s := APScript new name: #setFoo; sourceCode: 'foo := 42'.
	w addScript: s.
	s evaluate.
	self assert: w foo equals: 42
]
