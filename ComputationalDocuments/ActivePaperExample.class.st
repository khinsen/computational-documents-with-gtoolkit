Class {
	#name : #ActivePaperExample,
	#superclass : #ActivePaper,
	#instVars : [
		'#n => ObservableSlot'
	],
	#category : #ComputationalDocuments
}

{ #category : #'error situations' }
ActivePaperExample >> modificationByUnauthorizedMethod [
	n := 42
]

{ #category : #parameters }
ActivePaperExample >> n [
	^n
]

{ #category : #parameters }
ActivePaperExample >> n: anInteger [
	<apComputes: #n>
	n := anInteger
]
