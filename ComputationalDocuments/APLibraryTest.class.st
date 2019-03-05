Class {
	#name : #APLibraryTest,
	#superclass : #TestCase,
	#instVars : [
		'library'
	],
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #running }
APLibraryTest >> setUp [
	super setUp.
	library := APLibrary new.
	library useMemoryFilesystem
]

{ #category : #running }
APLibraryTest >> tearDown [
	library directory deleteAll.
	super tearDown
]

{ #category : #tests }
APLibraryTest >> testAddAndRemoveDocument [
	| d |
	d := APDocument name: #foo.
	library add: d.
	self assert: (library documentNamed: #foo) == d.
	library removeDocumentNamed: #foo.
	self assert: library size equals: 0.
]

{ #category : #tests }
APLibraryTest >> testErrorAddMultipleDocumentsWithSameName [
	| d1 d2 |
	d1 := APDocument name: #foo.
	d2 := APDocument name: #foo.
	library add: d1.
	self assert: (library documentNamed: #foo) == d1.
	self should: [ library add: d2 ] raise: Error.

]

{ #category : #tests }
APLibraryTest >> testErrorRemoveNonexistentDocument [
	self should: [ library removeDocumentNamed: #foo ] raise: Error.

]

{ #category : #tests }
APLibraryTest >> testStoreDocument [
	| d |
	d := APDocument name: #foo.
	library add: d.
	library storeDocumentNamed: #foo.

]
