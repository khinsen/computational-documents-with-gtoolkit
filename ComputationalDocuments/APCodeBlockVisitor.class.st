Class {
	#name : #APCodeBlockVisitor,
	#superclass : #PRVisitor,
	#instVars : [
		'labelledCodeBlocks'
	],
	#category : #'ComputationalDocuments-GToolkit'
}

{ #category : #initializing }
APCodeBlockVisitor >> initialize [
	super initialize.
	labelledCodeBlocks := Dictionary new
]

{ #category : #accessing }
APCodeBlockVisitor >> labelledCodeBlocks [
	^ labelledCodeBlocks
]

{ #category : #'visiting-document' }
APCodeBlockVisitor >> visitCodeblock: aCodeBlock [
	aCodeBlock hasLabel ifTrue:
		[ labelledCodeBlocks at: aCodeBlock label
									ifPresent: [ self error: 'redefinition of code block ', aCodeBlock label ]
									ifAbsentPut: [ aCodeBlock ] ].
	super visitCodeblock: aCodeBlock
]
