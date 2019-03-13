Class {
	#name : #APLibrary,
	#superclass : #Object,
	#instVars : [
		'documents',
		'directory'
	],
	#category : #ComputationalDocuments
}

{ #category : #accessing }
APLibrary class >> directory: aDirectory [
	^self basicNew
			initializeWithDirectory: aDirectory;
			yourself

]

{ #category : #files }
APLibrary class >> inLocalDirectory [
	^ self directory: FileLocator localDirectory / 'activepapers'
]

{ #category : #files }
APLibrary class >> inMemoryFilesystem [
	^ self directory: FileSystem currentMemoryFileSystem root / 'activepapers'
]

{ #category : #operations }
APLibrary >> add: anAPDocument [
	documents at: anAPDocument name
				 ifPresent: [ self error: 'Document name #', anAPDocument name, ' already in use' ]
				 ifAbsentPut: anAPDocument.
	anAPDocument library: self
]

{ #category : #files }
APLibrary >> directory [
	^ directory
]

{ #category : #accessing }
APLibrary >> documentNamed: aSymbol [
	| document |
	document := documents at: aSymbol
								 ifAbsent: [ self error: 'No document named ', aSymbol ].
	document ifNil: [ documents at: aSymbol put: (self retrieveDocumentNamed: aSymbol) ].
	^ documents at: aSymbol
]

{ #category : #accessing }
APLibrary >> documentNames [
	^ documents keys
]

{ #category : #files }
APLibrary >> fileReferenceForDocumentNamed: aSymbol [
	^ directory / (aSymbol, '.fuel')
]

{ #category : #inspecting }
APLibrary >> gtDocumentsFor: aView [
	<gtView>

	^ aView list
		title: 'Documents' translated;
		priority: 50;
		items: [ self lazyDocuments ];
		itemFormat: [ :each | each name ];
		actionButtonIcon: BrGlamorousIcons add asElement
			action: [ :aButton | self newUnnamedDocument ].
]

{ #category : #initializing }
APLibrary >> initializeWithDirectory: aDirectory [
	directory := aDirectory.
	directory ensureCreateDirectory.
	documents := Dictionary new.
	self scanDirectory
]

{ #category : #inspecting }
APLibrary >> lazyDocuments [
	| lazyDocuments |
	lazyDocuments := documents copy.
	lazyDocuments keysDo:
		[ :name |
			(lazyDocuments at: name)
				ifNil: [ lazyDocuments at: name
											  put: (APDocumentProxy name: name library: self) ] ].
	^ lazyDocuments values
]

{ #category : #operations }
APLibrary >> newDocumentNamed: aSymbol [
	| document |
	document := APDocument name: aSymbol.
	self add: document.
	^ document
]

{ #category : #operations }
APLibrary >> newUnnamedDocument [
	| number name |
	number := 0.
	[ number := number + 1.
	  name := 'Unnamed-', number asString.
	  documents includesKey: name asSymbol ]
	whileTrue.
	self newDocumentNamed: name
]

{ #category : #printing }
APLibrary >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	directory path printOn: aStream.
	aStream nextPut: $).
]

{ #category : #operations }
APLibrary >> removeDocumentNamed: aSymbol [
	documents removeKey: aSymbol
				 ifAbsent: [ self error: 'No document named ', aSymbol ]
]

{ #category : #files }
APLibrary >> retrieveDocumentNamed: aSymbol [
	^ APDocument fromFile: (self fileReferenceForDocumentNamed: aSymbol)
]

{ #category : #files }
APLibrary >> scanDirectory [
	(directory filesMatching: '*.fuel')
		do: [ :each | documents at: each basenameWithoutExtension
									  ifAbsentPut:  nil ]
]

{ #category : #accessing }
APLibrary >> size [
	^ documents size
]

{ #category : #private }
APLibrary >> store: anAPDocument inFile: aFileReference [
	aFileReference
		binaryWriteStreamDo: [ :stream | FLSerializer serialize: anAPDocument on: stream ]
	
]

{ #category : #files }
APLibrary >> storeDocumentNamed: aSymbol [
	documents at: aSymbol
		ifPresent: [ :d | d storeInFile: (self fileReferenceForDocumentNamed: d name) ]
		ifAbsent: [ self error: 'No document named ', aSymbol ]
]
