Class {
	#name : #APScriptWorkflow,
	#superclass : #Object,
	#traits : 'TAPOldData',
	#classTraits : 'TAPOldData classTrait',
	#instVars : [
		'apScripts',
		'apDataDependencies',
		'apComputingScripts'
	],
	#category : #'ComputationalDocuments-scriptBased'
}

{ #category : #'instance variables' }
APScriptWorkflow class >> addInstVarNamed: aString [
	"Override instance variable creation to make read and write access to all
	instance variables observable. Notify the uniqueInstance of every change."

	| newInstVarNames |

	"Apply special treatment only to subclasses"
	self = APScriptWorkflow
		ifTrue: [ ^ super addInstVarNamed: aString ].

	newInstVarNames := aString substrings.
	newInstVarNames ifEmpty: [ ^ self ].

	"Replace all new instance variables by APDataSlots"
	newInstVarNames do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (APOldDataSlot named: varSymbol).
		self compile: each , ' self apCompute: #', each, '. ^ ', each.
		(self compiledMethodAt: varSymbol) protocol: 'generated' ].

	"Invalidate cached state and put the new slot(s) under observation"
	self allInstancesDo:
		[ :each |
			self initializeSlots: each.
			each apClearCachedState.
			each apObserveAllSlots ].

]

{ #category : #testing }
APScriptWorkflow class >> isAbstract [
	^ true
]

{ #category : #'instance creation' }
APScriptWorkflow class >> name: aSymbol [
	self isAbstract
		ifTrue: "self is APWorkflow"
			[ | subclass |
			  subclass := self newAnonymousSubclass.
			  subclass class compile: 'isAbstract ^ false'.
			  subclass class compile: 'name ^ ''APScriptWorkflowFor', aSymbol , ''''.
			  ^ subclass new ]
		ifFalse: "self is an anonymous subclass of APWorkflow"
			[ ^ self error: 'Instances are created using ''APScriptWorkflow name: #aSymbol''' ]

]

{ #category : #'instance variables' }
APScriptWorkflow class >> removeInstVarNamed: aString [

	"Invalidate cached state and put the new slot(s) under observation"
	self allInstancesDo: [ :each | each apClearCachedState ].

	"Remove the auto-generated accessor method"
	self removeSelector: aString asSymbol.

	"Remove the slot"
	^ super removeInstVarNamed: aString.

]

{ #category : #comparing }
APScriptWorkflow >> = anObject [
	| instVarNames |
	(anObject class inheritsFrom: APWorkflow) ifFalse: [ ^ false ].
	instVarNames := self class instVarNames.
	instVarNames = anObject class instVarNames ifFalse: [ ^ false ].	
	instVarNames
		detect:
			[ :name | (self readSlotNamed: name) ~= (anObject readSlotNamed: name) ]
		ifFound: [ ^ false ].
	self flag: 'compare scripts'.
	^ true

]

{ #category : #accessing }
APScriptWorkflow >> addScript: aScript [
	aScript workflow: self.
	apScripts at: aScript name put: aScript.

]

{ #category : #dependencies }
APScriptWorkflow >> apClearCachedState [
	apComputingScripts := nil.
	apDataDependencies := Dictionary new.

]

{ #category : #dependencies }
APScriptWorkflow >> apCompute: aSymbol [
	"If the slot holds a non-nil value, consider the data available.
	 TODO: Should be replaced by an explicit validity flag stored in APValueHolder."
	self flag: 'todo'
]

{ #category : #'data access' }
APScriptWorkflow >> apComputedVariablesInThisContext [
	| computedVariables level context |
	computedVariables := Dictionary new.
	level := 1.
	context := thisContext.
	[ context isNil ] whileFalse:
		[ context := context findContextSuchThat:
			[ :c | c methodClass = self class ].
		  context ifNotNil:
			[ context method pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | computedVariables at: p arguments first ifAbsentPut: level ].
			  context := context sender.
			  level := level + 1 ] ].
	^ computedVariables
]

{ #category : #dependencies }
APScriptWorkflow >> apDataDependencies [
	^ apDataDependencies
]

{ #category : #dependencies }
APScriptWorkflow >> apMake: aVariable dependencyOf: dependentVariable [
	(apDataDependencies at: dependentVariable ifAbsentPut: [ Set new ])
		add: aVariable
]

{ #category : #'data access' }
APScriptWorkflow >> apObserveAllSlots [
	self class slots do:
		[ :slot | self apObserveSlot: slot name ]
]

{ #category : #'data access' }
APScriptWorkflow >> apObserveSlot: aSymbol [
	self property: aSymbol
		  whenReadDo:
				[ self apReadAccessTo: aSymbol ].
	self property: aSymbol
		  whenChangedDo:
				[ :value | self apValueOf: aSymbol setTo: value ]
]

{ #category : #'data access' }
APScriptWorkflow >> apReadAccessTo: aSymbol [
	| variables |
	variables := self apComputedVariablesInThisContext.
	variables ifEmpty: [ ^ self ].
	"Read access by the defining method requires no action."
	variables at: aSymbol ifPresent: [ :level | level = 1 ifTrue: [ ^ self ] ].
	"If the defining method is in the list, but not in the first place, there is
	 a cycle in the data dependency graph."
	self assert: (variables includesKey: aSymbol) not
		  description: 'Cyclic data dependency:',
							aSymbol,
							' -> ',
							(' -> ' join: variables keys).
	"Otherwise, record a dependency for variable being computed."
	variables keysAndValuesDo:
		[ :v :l | l = 1 ifTrue: [ self apMake: aSymbol dependencyOf: v ] ]
	
]

{ #category : #'data access' }
APScriptWorkflow >> apValueHolderFor: aSymbol [
	^ (self class slotNamed: aSymbol) rawRead: self
]

{ #category : #'data access' }
APScriptWorkflow >> apValueOf: aSymbol setTo: aValue [
	| variables |
	variables := self apComputedVariablesInThisContext.
	variables ifEmpty: [ ^ self ].
	self assert: (variables includesKey: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]

{ #category : #serialization }
APScriptWorkflow >> fuelAccept: aGeneralMapper [
	| slotContents scripts |
	slotContents := Dictionary new.
	self class localSlots
		do: [ :slot |
				| valueHolder |
				valueHolder := slot rawRead: self.
				slotContents at: slot name
								 put: { valueHolder isValid.
										  valueHolder value.
										  valueHolder timeStamp } ].
	self flag: 'store scripts'.
	scripts := nil.

	^ aGeneralMapper
		visitSubstitution: self
		by: { slotContents. scripts. apDataDependencies }
]

{ #category : #comparing }
APScriptWorkflow >> hash [
	| instVarNames hash |
	instVarNames := self class instVarNames.
	hash := instVarNames hash.
	instVarNames do:
		[ :name |
			hash := hash bitXor: (self readSlotNamed: name) hash ].
	self flag: 'hash scripts'.
	^ hash

]

{ #category : #initialization }
APScriptWorkflow >> initialize [
	super initialize.
	self class initializeSlots: self.
	apScripts := Dictionary new.
	self apObserveAllSlots.
	self apClearCachedState.

]

{ #category : #dependencies }
APScriptWorkflow >> restoreDataDependenciesTo: aDictionary [
	"Used only to restore dependencies from a serialized APDocument"
	apDataDependencies := aDictionary
]

{ #category : #accessing }
APScriptWorkflow >> scriptNamed: aSymbol [
	^ apScripts at: aSymbol
]

{ #category : #accessing }
APScriptWorkflow >> scripts [
	^ apScripts
]
