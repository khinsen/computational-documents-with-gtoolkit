Class {
	#name : #ActivePaperExample2,
	#superclass : #ActivePaper,
	#instVars : [
		'#n => APDataSlot'
	],
	#category : #ComputationalDocuments
}

{ #category : #'error situations' }
ActivePaperExample2 >> modificationByUnauthorizedMethod [
	n := 42
]

{ #category : #accessing }
ActivePaperExample2 >> n [
	^ n
]

{ #category : #accessing }
ActivePaperExample2 >> n: anInteger [
	<apComputes: #n>
	n := anInteger
]
