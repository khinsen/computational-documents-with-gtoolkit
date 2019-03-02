Class {
	#name : #APLibraryTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APLibraryTest >> testAddAndRemoveDocument [
	| l d |
	l := APLibrary new.
	d := APDocument name: #foo.
	l add: d.
	self assert: (l documentNamed: #foo) == d.
	l removeDocumentNamed: #foo.
	self assert: l size equals: 0.
]

{ #category : #tests }
APLibraryTest >> testErrorAddMultipleDocumentsWithSameName [
	| l d1 d2 |
	l := APLibrary new.
	d1 := APDocument name: #foo.
	d2 := APDocument name: #foo.
	l add: d1.
	self assert: (l documentNamed: #foo) == d1.
	self should: [ l add: d2 ] raise: Error.

]

{ #category : #tests }
APLibraryTest >> testErrorRemoveNonexistentDocument [
	| l |
	l := APLibrary new.
	self should: [ l removeDocumentNamed: #foo ] raise: Error.

]
