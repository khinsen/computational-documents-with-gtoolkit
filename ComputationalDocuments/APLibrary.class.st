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
APLibrary >> add: anAPDocument [
	documents at: anAPDocument name
				 ifPresent: [ self error: 'Document name #', anAPDocument name, ' already in use' ]
				 ifAbsentPut: anAPDocument
]

{ #category : #files }
APLibrary >> directory [
	^ directory
]

{ #category : #files }
APLibrary >> directory: aDirectory [
	directory := aDirectory.
	directory ensureCreateDirectory.
]

{ #category : #accessing }
APLibrary >> documentNamed: aSymbol [
	^ documents at: aSymbol
					ifAbsent: [ self error: 'No document named ', aSymbol ]
]

{ #category : #initialization }
APLibrary >> initialize [
	documents := Dictionary new.
]

{ #category : #accessing }
APLibrary >> removeDocumentNamed: aSymbol [
	documents removeKey: aSymbol
				 ifAbsent: [ self error: 'No document named ', aSymbol ]
]

{ #category : #accessing }
APLibrary >> size [
	^ documents size
]

{ #category : #files }
APLibrary >> store: anAPDocument [
	| filename |
	filename := anAPDocument name, '.fuel'.
	(directory / filename)
		binaryWriteStreamDo: [ :stream | FLSerializer serialize: anAPDocument on: stream ]
	
]

{ #category : #files }
APLibrary >> storeDocumentNamed: aSymbol [
	documents at: aSymbol
		ifPresent: [ :d | self store: d ]
		ifAbsent: [ self error: 'No document named ', aSymbol ]
]

{ #category : #files }
APLibrary >> useLocalDirectory [
	self directory: FileLocator localDirectory / 'activepapers'
]

{ #category : #files }
APLibrary >> useMemoryFilesystem [
	self directory: FileSystem currentMemoryFileSystem root / 'activepapers'
]
