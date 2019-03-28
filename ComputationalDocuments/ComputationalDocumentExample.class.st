Class {
	#name : #ComputationalDocumentExample,
	#superclass : #ComputationalDocument,
	#instVars : [
		'inputData'
	],
	#category : #'ComputationalDocuments-Obsolete'
}

{ #category : #initialization }
ComputationalDocumentExample >> initialize [
	| lines |
	super initialize.
	lines := #( '!A simple computation'
					''
					'The input data is:'
					'[[['
					'self inputData: #(1 3 5 7)'
					']]]'
					''
					'The squares of these numbers are:'
					'[[['
					'self squares'
					']]]'
					).
	self story: (Character cr asString join: lines).
]

{ #category : #accessing }
ComputationalDocumentExample >> inputData [
	^ inputData
]

{ #category : #accessing }
ComputationalDocumentExample >> inputData: aNumberCollection [
	inputData := aNumberCollection
]

{ #category : #accessing }
ComputationalDocumentExample >> name [
	^ 'anExample'
]

{ #category : #computing }
ComputationalDocumentExample >> squares [
	^ self inputData collect: [ :each | each * each ]
]
