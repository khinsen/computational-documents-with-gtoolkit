"
I represent a live document with computations.
"
Class {
	#name : #ActivePaper,
	#superclass : #Object,
	#traits : 'TSingleton + TObservable',
	#classTraits : 'TSingleton classTrait + TObservable classTrait',
	#instVars : [
		'document'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance variables' }
ActivePaper class >> addInstVarNamed: aString [
	"Override instance variable creation to make all instance variables APDataSlots."

	aString substrings do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (APDataSlot named: varSymbol) ]

]

{ #category : #'data access' }
ActivePaper >> announceReadAccessTo: aSymbol [
	^ self
]

{ #category : #'data access' }
ActivePaper >> announceWriteAccessTo: aSymbol [
	| variables |
	Transcript crLog: 'Writing ' , aSymbol asString.
	variables := self computedVariablesInContext.
	self assert: (variables includes: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]

{ #category : #'data access' }
ActivePaper >> computedVariablesInContext [
	| context computedVariables |
	computedVariables := Set new.
	context := thisContext.
	[ context isNil ] whileFalse:
		[ context := context findContextSuchThat:
			[ :c | c methodClass inheritsFrom: ActivePaper ].
		  context isNil ifFalse:
			[ context method pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | computedVariables add: p arguments first ].
			  context := context sender ] ].
	^computedVariables
]

{ #category : #initializing }
ActivePaper >> initialize [
	super initialize.
	self class initializeSlots: self.
]
