Class {
	#name : #APLibrary,
	#superclass : #Object,
	#instVars : [
		'documents'
	],
	#category : #ComputationalDocuments
}

{ #category : #accessing }
APLibrary >> add: anAPDocument [
	documents at: anAPDocument name
				 ifPresent: [ self error: 'Document name #', anAPDocument name, ' already in use' ]
				 ifAbsentPut: anAPDocument
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
