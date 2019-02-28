Class {
	#name : #APDynamicWorkflow,
	#superclass : #Object,
	#traits : 'TSingleton + TAPData',
	#classTraits : 'TSingleton classTrait + TAPData classTrait',
	#instVars : [
		'apDataDependencies'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance variables' }
APDynamicWorkflow class >> addInstVarNamed: aString [
	"Override instance variable creation to make read and write access to all
	instance variables observable. Notify the uniqueInstance of every change."

	| newInstVarNames |

	"Apply special treatment only to subclasses"
	self = APDynamicWorkflow ifTrue: [ ^ super addInstVarNamed: aString ].

	newInstVarNames := aString substrings.
	newInstVarNames ifEmpty: [ ^ self ].

	"Replace all new instance variables by APDataSlots"
	newInstVarNames do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (APDataSlot named: varSymbol).
		self compile: each , ' ^ self apCompute: #', each ].

	"Put all slots under observation"
	uniqueInstance ifNotNil:
		[ uniqueInstance apObserveAllSlots ]
]

{ #category : #testing }
APDynamicWorkflow class >> isAbstract [
	^ true
]

{ #category : #'instance creation' }
APDynamicWorkflow class >> new [
	^ self newAnonymousSubclass uniqueInstance
]

{ #category : #'data access' }
APDynamicWorkflow >> apComputedVariablesInThisContext [
	| context computedVariables |
	computedVariables := OrderedCollection new.
	context := thisContext.
	[ context isNil ] whileFalse:
		[ context := context findContextSuchThat:
			[ :c | c methodClass inheritsFrom: self class ].
		  context isNil ifFalse:
			[ context method pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | computedVariables add: p arguments first ].
			  context := context sender ] ].
	^ computedVariables
]

{ #category : #dependencies }
APDynamicWorkflow >> apMake: aVariable dependencyOf: dependentVariable [
	(apDataDependencies at: dependentVariable ifAbsentPut: [ Set new ])
		dependencies add: aVariable
]

{ #category : #'data access' }
APDynamicWorkflow >> apObserveAllSlots [
	self class slots do:
		[ :slot | self property: slot name
							whenReadDo:
								[ self apReadAccessTo: slot name ].
					 self property: slot name
							whenChangedDo:
								[ :value | self apValueOf: slot name setTo: value ] ]
]

{ #category : #'data access' }
APDynamicWorkflow >> apReadAccessTo: aSymbol [
	| variables |
	variables := self apComputedVariablesInThisContext.
	"Read access by the defining method requires no action."
	variables first = aSymbol ifTrue: [ ^ self ].
	"If the defining method is in the list, but not in the first place, there is
	 a cycle in the data dependency graph."
	self assert: (variables includes: aSymbol) not
		  description: 'Cyclic data dependency:',
							aSymbol,
							' -> ',
							(' -> ' join: variables).
	"Otherwise, record a dependency."
	self apMake: aSymbol dependencyOf: variables first
]

{ #category : #'data access' }
APDynamicWorkflow >> apValueOf: aSymbol setTo: aValue [
	| variables |
	variables := self apComputedVariablesInThisContext.
	self assert: (variables includes: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]

{ #category : #initialization }
APDynamicWorkflow >> initialize [
	super initialize.
	self class initializeSlots: self.
	self apObserveAllSlots.
	apDataDependencies := Dictionary new.
]
