Class {
	#name : #APDocumentTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APDocumentTest >> testDataDefinitionAndRetrieval [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineScript: 'setX <apComputes: #x> x := 42'.
	self assert: (d datasetNamed: #x) equals: 42.
]

{ #category : #tests }
APDocumentTest >> testDependencyChain [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineDatasetNamed: #y.
	d defineDatasetNamed: #z.
	d defineScript: 'computeX <apComputes: #x> x := 1'.
	d defineScript: 'computeY <apComputes: #y> y := x + 1'.
	d defineScript: 'computeZ <apComputes: #z> z := y + 1'.
	"Ultimately, explicit runScript: should not be necessary"
	d runScript: #computeX.
	d runScript: #computeY.
	d runScript: #computeZ.

	self assert: d scriptNames equals: #(computeX computeY computeZ) asSet.
	self assert: d datasetNames equals: #(x y z) asSet.

	self assert: (d datasetNamed: #x) equals: 1.
	self assert: (d datasetNamed: #y) equals: 2.
	self assert: (d datasetNamed: #z) equals: 3.


]

{ #category : #tests }
APDocumentTest >> testEquality [
	| d1 d2 |
	d1 := APDocument name: #foo.
	d1 defineDatasetNamed: #x.
	d1 defineScript: 'setX <apComputes: #x> x := 42'.
	self assert: (d1 datasetNamed: #x) equals: 42.

	d2 := APDocument name: #foo.
	d2 defineDatasetNamed: #x.
	d2 defineScript: 'setX <apComputes: #x> x := 42'.
	self assert: (d2 datasetNamed: #x) equals: 42.

	self assert: d1 equals: d2.
]

{ #category : #tests }
APDocumentTest >> testErrorComputingMethodRequiresArguments [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineScript: 'setX: anInteger <apComputes: #x> x := anInteger'.
	"The first computation should raise an error"
	self should: [ d datasetNamed: #x ] raise: Error.
]

{ #category : #tests }
APDocumentTest >> testErrorTwoMethodsComputeSameVariable [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineScript: 'computeX1 <apComputes: #x> x := 42'.
	d defineScript: 'computeX2 <apComputes: #x> x := 11'.
	"The first computation should raise an error"
	self should: [ d datasetNamed: #x ] raise: Error.
]

{ #category : #tests }
APDocumentTest >> testErrorUncomputedInstVar [
	| d |	
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineDatasetNamed: #y.
	d defineScript: 'computeX <apComputes: #x> x := 1'.
	"The first computation should raise an error"
	self should: [ d datasetNamed: #x ] raise: Error.
]

{ #category : #tests }
APDocumentTest >> testErrorUndeclaredComputedVar [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineScript: 'computeX <apComputes: #x> x := 1'.
	d defineScript: 'computeY <apComputes: #y> x := 1'.
	"The first computation should raise an error"
	self should: [ d datasetNamed: #x ] raise: Error.
]
