Class {
	#name : #APDynamicWorkflowTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APDynamicWorkflowTest >> testDataDefinitionAndRetrieval [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX <apComputes: #x> x := 42'.
	self assert: wf x equals: 42.
]

{ #category : #tests }
APDynamicWorkflowTest >> testDependencyChain [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x y z'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	wf class compile: 'computeY <apComputes: #y> y := x + 1'.
	wf class compile: 'computeZ <apComputes: #z> z := y + 1'.
	self assert: wf x equals: 1.
	self assert: wf y equals: 2.
	self assert: wf z equals: 3
]

{ #category : #tests }
APDynamicWorkflowTest >> testErrorTwoMethodsComputeSameVariable [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX1 <apComputes: #x> x := 42'.
	wf class compile: 'setX2 <apComputes: #x> x := 11'.
	"The first computation should raise an error"
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APDynamicWorkflowTest >> testErrorUncomputedInstVar [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x y'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APDynamicWorkflowTest >> testErrorUndeclaredComputedVar [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	wf class compile: 'setY <apComputes: #y> x := 1'.
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APDynamicWorkflowTest >> testInstVarCreation [
	| wf |
	wf := APDynamicWorkflow new.
	wf class addInstVarNamed: 'x'.
	self assert: (wf class slotNamed: #x) isObservableSlot.
	self assert: ((wf observablePropertyNamed: #x) isKindOf: APValueHolder).
	"There is no method for computing x, so access to x is an error."
	self should: [ wf x ] raise: Error.
]
