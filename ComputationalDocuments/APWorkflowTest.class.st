Class {
	#name : #APWorkflowTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APWorkflowTest >> testDataDefinitionAndRetrieval [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX <apComputes: #x> x := 42'.
	self assert: wf x equals: 42.
]

{ #category : #tests }
APWorkflowTest >> testDependencyChain [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x y z'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	wf class compile: 'computeY <apComputes: #y> y := x + 1'.
	wf class compile: 'computeZ <apComputes: #z> z := y + 1'.
	self assert: wf x equals: 1.
	self assert: wf y equals: 2.
	self assert: wf z equals: 3
]

{ #category : #tests }
APWorkflowTest >> testEquality [
	| wf1 wf2 |
	wf1 := APWorkflow name: #foo.
	wf1 class addInstVarNamed: 'x'.
	wf1 class compile: 'setX <apComputes: #x> x := 42'.
	self assert: wf1 x equals: 42.

	wf2 := APWorkflow name: #foo.
	wf2 class addInstVarNamed: 'x'.
	wf2 class compile: 'setX <apComputes: #x> x := 42'.
	self assert: wf2 x equals: 42.

	self assert: wf1 equals: wf2
]

{ #category : #tests }
APWorkflowTest >> testErrorComputingMethodRequiresArguments [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX: anInteger <apComputes: #x> x := 42'.
	"The first computation should raise an error"
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APWorkflowTest >> testErrorTwoMethodsComputeSameVariable [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX1 <apComputes: #x> x := 42'.
	wf class compile: 'setX2 <apComputes: #x> x := 11'.
	"The first computation should raise an error"
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APWorkflowTest >> testErrorUncomputedInstVar [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x y'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APWorkflowTest >> testErrorUndeclaredComputedVar [
	| wf |
	wf := APWorkflow name: #foo.
	wf class addInstVarNamed: 'x'.
	wf class compile: 'setX <apComputes: #x> x := 1'.
	wf class compile: 'setY <apComputes: #y> x := 1'.
	self should: [ wf x ] raise: Error.
]

{ #category : #tests }
APWorkflowTest >> testInstVarAndScriptCreation [
	| wf |
	wf := APWorkflow name: #foo.
	
	wf class addInstVarNamed: 'x'.
	self assert: (wf class slotNamed: #x) isObservableSlot.
	self assert: ((wf observablePropertyNamed: #x) isKindOf: APValueHolder).
	self assert: wf class workflowMethods isEmpty.
	self assert: (wf class methods select: [ :each | each protocol = 'generated']) size equals: 1.
	"There is no method for computing x, so access to x is an error."
	self should: [ wf x ] raise: Error.
	
	wf class compile: 'setX <apComputes: #x> x := 42'.
	self assert: wf class workflowMethods size equals: 1.
	self assert: (wf class methods select: [ :each | each protocol = 'generated']) size equals: 1.

]
