Class {
	#name : #APDynamicWorkflowTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APDynamicWorkflowTest >> testDependencyChain [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x y z'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	wf class compile: 'computeY <apComputes: #y> y := x + 1'.
	wf class compile: 'computeZ <apComputes: #z> z := y + 1'.
	self assert: wf z equals: 3
]

{ #category : #tests }
APDynamicWorkflowTest >> testInstVarCreation [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x'.
	self assert: (wf class slotNamed: #x) isObservableSlot.
	self assert: (wf class observablePropertyNamed: #x) isKindOf: APDataSlot.
	self assert: wf x equals: nil
]
