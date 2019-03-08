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

{ #category : #accessing }
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

{ #category : #initializing }
APLibrary >> initializeWithDirectory: aDirectory [
	directory := aDirectory.
	directory ensureCreateDirectory.
	documents := Dictionary new.
	self scanDirectory
]

{ #category : #accessing }
APLibrary >> removeDocumentNamed: aSymbol [
	documents removeKey: aSymbol
				 ifAbsent: [ self error: 'No document named ', aSymbol ]
]

{ #category : #files }
APLibrary >> retrieveDocumentNamed: aSymbol [
	^ (self fileReferenceForDocumentNamed: aSymbol)
		binaryReadStreamDo:
			[ :stream |
					(FLMaterializer newDefault
						materializeFrom: stream) root ].
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
		ifPresent: [ :d | self store: d
									 inFile: 	(self fileReferenceForDocumentNamed: d name) ]
		ifAbsent: [ self error: 'No document named ', aSymbol ]
]
