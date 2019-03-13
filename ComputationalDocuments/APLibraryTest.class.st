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
	library := APLibrary inMemoryFilesystem
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
APLibraryTest >> testCreateStoreAndRetrieveBigDocument [
	| d retrieved |

	d := library newDocumentNamed: #FluDataset.
	d defineDatasetNamed: #rawData.
	d defineDatasetNamed: #retrievalDateAndTime.
	d defineScript: 'downloadRawData
	<apComputes: #rawData>
	<apComputes: #retrievalDatAndTime>
	rawData := ''http://www.sentiweb.fr/datasets/incidence-PAY-3.csv'' asZnUrl retrieveContents.
	retrievalDataAndTime := DateAndTime now.'.
	d runScript: #downloadRawData.
	d store.

	retrieved := library retrieveDocumentNamed: #FluDataset.
	self assert: retrieved equals: d
]

{ #category : #tests }
APLibraryTest >> testCreateStoreAndRetrieveDocument [
	| d l2 retrieved |

	d := library newDocumentNamed: #FluDataset.
	d defineDatasetNamed: #rawData.
	d defineDatasetNamed: #retrievalDateAndTime.
	d defineScript: 'downloadRawData
	<apComputes: #rawData>
	<apComputes: #retrievalDateAndTime>
	"To keep the test free of network access, we just record the URL"
	rawData := ''http://www.sentiweb.fr/datasets/incidence-PAY-3.csv''.
	retrievalDateAndTime := DateAndTime now.'.
	d runScript: #downloadRawData.
	d store.

	l2 := APLibrary inMemoryFilesystem.
	retrieved := l2 retrieveDocumentNamed: #FluDataset.
	self assert: retrieved equals: d
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
APLibraryTest >> testScanDirectory [
	| d l |

	#(foo bar baz quux) do:
		[ :name |
		  d := APDocument name: name.
		  d defineDatasetNamed: #x.
		  d defineScript: 'setX <apComputes: #x> x := 42'.
		  self assert: (d datasetNamed: #x) equals: 42.
		  library add: d.
		  d store ].

	l := APLibrary inMemoryFilesystem.
	self assert: l size equals: 4.
	l documentNames do:
		[ :name | self assert: (l retrieveDocumentNamed: name)
							equals: (library retrieveDocumentNamed: name) ]
]

{ #category : #tests }
APLibraryTest >> testStoreAndRetrieveDocument [
	| d retrieved |

	d := APDocument name: #foo.
	d defineDatasetNamed: #x.
	d defineScript: 'setX <apComputes: #x> x := 42'.
	self assert: (d datasetNamed: #x) equals: 42.

	library add: d.
	d store.

	retrieved := library retrieveDocumentNamed: #foo.
	self assert: retrieved equals: d
]
