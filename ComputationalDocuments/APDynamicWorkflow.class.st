Class {
	#name : #APDynamicWorkflow,
	#superclass : #Object,
	#traits : 'TSingleton + TAPData',
	#classTraits : 'TSingleton classTrait + TAPData classTrait',
	#instVars : [
		'apDataDependencies',
		'apComputingMethods'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance variables' }
APDynamicWorkflow class >> addInstVarNamed: aString [
	"Override instance variable creation to make read and write access to all
	instance variables observable. Notify the uniqueInstance of every change."

	| newInstVarNames |

	"Apply special treatment only to subclasses"
	self = APDynamicWorkflow
		ifTrue: [ ^ super addInstVarNamed: aString ].

	newInstVarNames := aString substrings.
	newInstVarNames ifEmpty: [ ^ self ].

	"Replace all new instance variables by APDataSlots"
	newInstVarNames do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (APDataSlot named: varSymbol).
		uniqueInstance ifNotNil:
			[ (self slotNamed: varSymbol) initialize: uniqueInstance.
			  uniqueInstance apObserveSlot: varSymbol ].
		self compile: each , ' ^ self apCompute: #', each ]
]

{ #category : #testing }
APDynamicWorkflow class >> isAbstract [
	^ true
]

{ #category : #'instance creation' }
APDynamicWorkflow class >> new [
	| subclass |
	subclass := self newAnonymousSubclass.
	subclass class compile: 'isAbstract ^ false'.
	subclass class compile: 'name ^ ''APDynamicWorkflow+'''.
	^ subclass uniqueInstance
]

{ #category : #computation }
APDynamicWorkflow >> apCompute: aSymbol [
	self collectComputingMethods.
	(apComputingMethods at: aSymbol)
		valueWithReceiver: self arguments: Array new.
	^ self readSlotNamed: aSymbol
]

{ #category : #'data access' }
APDynamicWorkflow >> apComputedVariablesInThisContext [
	| context computedVariables |
	computedVariables := OrderedCollection new.
	context := thisContext.
	[ context isNil ] whileFalse:
		[ context := context findContextSuchThat:
			[ :c | c methodClass = self class ].
		  context ifNotNil:
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
		[ :slot | self apObserveSlot: slot ]
]

{ #category : #'data access' }
APDynamicWorkflow >> apObserveSlot: aSymbol [
	self property: aSymbol
		  whenReadDo:
				[ self apReadAccessTo: aSymbol ].
	self property: aSymbol
		  whenChangedDo:
				[ :value | self apValueOf: aSymbol setTo: value ]
]

{ #category : #'data access' }
APDynamicWorkflow >> apReadAccessTo: aSymbol [
	| variables |
	variables := self apComputedVariablesInThisContext.
	variables ifEmpty: [ ^ self ].
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

{ #category : #computation }
APDynamicWorkflow >> collectComputingMethods [
	| uncomputedInstVars computedUndeclaredVars |
	apComputingMethods := Dictionary new.
	(Pragma allNamed: #apComputes: in: self class) do:
		[ :each | apComputingMethods at: each arguments first
					 ifPresent: [ :earlier |
									  Error signal: 'Methods ', each method name,
															' and ', earlier method name,
															' both claim to compute ',
															each arguments first ]
					 ifAbsentPut: [ each method ] ].
	computedUndeclaredVars := apComputingMethods keys difference: self class instVarNames.
	computedUndeclaredVars ifNotEmpty: [ Error signal: 'Variables computed but not declared: ',
																		 (', ' join: computedUndeclaredVars) ].
	uncomputedInstVars := self class instVarNames difference: apComputingMethods keys.
	uncomputedInstVars ifNotEmpty: [ Error signal: 'Variables declared but not computed: ',
																	 (', ' join: uncomputedInstVars) ].
]

{ #category : #initialization }
APDynamicWorkflow >> initialize [
	super initialize.
	self class initializeSlots: self.
	self apObserveAllSlots.
	apDataDependencies := Dictionary new.
]
