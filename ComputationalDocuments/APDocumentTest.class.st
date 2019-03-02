Class {
	#name : #APDocumentTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APDocumentTest >> testSimpleWorkflow [
	| d |
	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineDatasetNamed: #y.
	d defineDatasetNamed: #z.
	d defineScript: 'computeX <apComputes: #x> x := 1'.
	d defineScript: 'computeY <apComputes: #y> y := x + 1'.
	d defineScript: 'computeZ <apComputes: #z> z := y + 1'.
	d runScript: #computeX.
	d runScript: #computeY.
	d runScript: #computeZ.

	self assert: d scriptNames equals: #(computeX computeY computeZ) asSet.
	self assert: d datasetNames equals: #(x y z) asSet.

	self assert: (d datasetNamed: #x) equals: 1.
	self assert: (d datasetNamed: #y) equals: 2.
	self assert: (d datasetNamed: #z) equals: 3.


]
