Class {
	#name : #APActivePaperTest,
	#superclass : #TestCase,
	#instVars : [
		'activePaper',
		'activePaperInstance'
	],
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #running }
APActivePaperTest >> setUp [
	EpMonitor current disable.
	activePaper := APActivePaper name: #APActivePaperTestExample.
	activePaperInstance := activePaper uniqueInstance.
]

{ #category : #running }
APActivePaperTest >> tearDown [
	activePaperInstance := nil.
	activePaper removeFromSystem.
	EpMonitor current enable.
]

{ #category : #testing }
APActivePaperTest >> testDataDefinitionAndRetrieval [
	activePaper addInstVarNamed: 'x'.
	activePaper compile: 'setX <apComputes: #x> x := 42'.
	self assert: activePaperInstance x equals: 42.
]

{ #category : #testing }
APActivePaperTest >> testDependencyChain [
	activePaper addInstVarNamed: 'x y z'.
	activePaper compile: 'setX <apComputes: #x> x := 1'.
	activePaper compile: 'computeY <apComputes: #y> y := x + 1'.
	activePaper compile: 'computeZ <apComputes: #z> z := y + 1'.
	self assert: activePaperInstance x equals: 1.
	self assert: activePaperInstance y equals: 2.
	self assert: activePaperInstance z equals: 3
]

{ #category : #testing }
APActivePaperTest >> testErrorComputingMethodRequiresArguments [
	activePaper addInstVarNamed: 'x'.
	activePaper compile: 'setX: anInteger <apComputes: #x> x := 42'.
	"The first computation should raise an error"
	self should: [ activePaperInstance x ] raise: Error.
]

{ #category : #testing }
APActivePaperTest >> testErrorTwoMethodsComputeSameVariable [
	activePaper addInstVarNamed: 'x'.
	activePaper compile: 'setX1 <apComputes: #x> x := 42'.
	activePaper compile: 'setX2 <apComputes: #x> x := 11'.
	"The first computation should raise an error"
	self should: [ activePaperInstance x ] raise: Error.
]

{ #category : #testing }
APActivePaperTest >> testErrorUncomputedInstVar [
	activePaper addInstVarNamed: 'x y'.
	activePaper compile: 'setX <apComputes: #x> x := 1'.
	self should: [ activePaperInstance x ] raise: Error.
]

{ #category : #testing }
APActivePaperTest >> testErrorUndeclaredComputedVar [
	activePaper addInstVarNamed: 'x'.
	activePaper compile: 'setX <apComputes: #x> x := 1'.
	activePaper compile: 'setY <apComputes: #y> x := 1'.
	self should: [ activePaperInstance x ] raise: Error.
]

{ #category : #testing }
APActivePaperTest >> testInstVarAndScriptCreation [
	activePaper addInstVarNamed: 'x'.
	self assert: (activePaper slotNamed: #x) isObservableSlot.
	self assert: ((activePaperInstance observablePropertyNamed: #x) isKindOf: APValueHolder).
	self assert: activePaper workflowMethods isEmpty.
	self assert: (activePaper methods select: [ :each | each protocol = 'generated']) size equals: 1.
	"There is no method for computing x, so access to x is an error."
	self should: [ activePaperInstance x ] raise: Error.
	
	activePaper compile: 'setX <apComputes: #x> x := 42'.
	self assert: activePaper workflowMethods size equals: 1.
	self assert: (activePaper methods select: [ :each | each protocol = 'generated']) size equals: 1.

]
