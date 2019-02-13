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
	"Override instance variable creation to make all instance variables observable.
	 Notify the uniqueInstance of every change."

	aString substrings do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (ObservableSlot named: varSymbol).
		uniqueInstance ifNotNil:
			[ uniqueInstance observeAllSlots ] ]

]

{ #category : #'access protection' }
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
	self observeAllSlots
]

{ #category : #'access protection' }
ActivePaper >> observeAllSlots [
	self class slots do:
		[ :slot | self property: slot name
							whenChangedDo:
								[ :value | self valueOf: slot name setTo: value ] ]
]

{ #category : #'access protection' }
ActivePaper >> valueOf: aSymbol setTo: aValue [
	| variables |
	variables := self computedVariablesInContext.
	self assert: (variables includes: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]
