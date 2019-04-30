Class {
	#name : #APWorkflow,
	#superclass : #Object,
	#traits : 'TAPOldData',
	#classTraits : 'TAPOldData classTrait',
	#instVars : [
		'apDataDependencies',
		'apComputingMethods'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance variables' }
APWorkflow class >> addInstVarNamed: aString [
	"Override instance variable creation to make read and write access to all
	instance variables observable. Notify the uniqueInstance of every change."

	| newInstVarNames |

	"Apply special treatment only to subclasses"
	self = APWorkflow
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
APWorkflow class >> isAbstract [
	^ true
]

{ #category : #'instance creation' }
APWorkflow class >> name: aSymbol [
	self isAbstract
		ifTrue: "self is APWorkflow"
			[ | subclass |
			  subclass := self newAnonymousSubclass.
			  subclass class compile: 'isAbstract ^ false'.
			  subclass class compile: 'name ^ ''APWorkflowFor', aSymbol , ''''.
			  ^ subclass new ]
		ifFalse: "self is an anonymous subclass of APWorkflow"
			[ ^ self error: 'Instances are created using ''APWorkflow name: #aSymbol''' ]

]

{ #category : #'instance variables' }
APWorkflow class >> removeInstVarNamed: aString [

	"Invalidate cached state and put the new slot(s) under observation"
	self allInstancesDo: [ :each | each apClearCachedState ].

	"Remove the auto-generated accessor method"
	self removeSelector: aString asSymbol.

	"Remove the slot"
	^ super removeInstVarNamed: aString.

]

{ #category : #'accessing-methods' }
APWorkflow class >> workflowMethods [
	^ self methods select: [ :each | each protocol ~= 'generated' and: [ each selector ~= #initialize ] ]
]

{ #category : #comparing }
APWorkflow >> = anObject [
	| instVarNames |
	(anObject class inheritsFrom: APWorkflow) ifFalse: [ ^ false ].
	instVarNames := self class instVarNames.
	instVarNames = anObject class instVarNames ifFalse: [ ^ false ].	
	instVarNames
		detect:
			[ :name | (self readSlotNamed: name) ~= (anObject readSlotNamed: name) ]
		ifFound: [ ^ false ].
	self class workflowMethods
		detect:
			[ :method |
				method sourceCode ~= (anObject class methodNamed: method selector) sourceCode ]
		ifFound: [ ^ false ].
	^ true

]

{ #category : #dependencies }
APWorkflow >> apClearCachedState [
	apComputingMethods := nil.
	apDataDependencies := Dictionary new.

]

{ #category : #dependencies }
APWorkflow >> apCollectComputingMethods [
	| uncomputedInstVars computedUndeclaredVars |
	apComputingMethods ifNotNil: [ ^ self ].
	apComputingMethods := Dictionary new.
	(Pragma allNamed: #apComputes: in: self class) do:
		[ :each |
			each method numArgs > 0
				ifTrue: [ Error signal: 'Method ', each method name,
													' computes ', each arguments first,
													' but requires arguments' ].
			apComputingMethods at: each arguments first
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

{ #category : #computation }
APWorkflow >> apCompute: aSymbol [
	"If the slot holds a non-nil value, consider the data available.
	 TODO: Should be replaced by an explicit validity flag stored in APValueHolder."
	(self instVarNamed: aSymbol) value ifNotNil: [ ^ self ]. 
	self apCollectComputingMethods.
	(apComputingMethods at: aSymbol)
		valueWithReceiver: self arguments: Array new

]

{ #category : #'data access' }
APWorkflow >> apComputedVariablesInThisContext [
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
APWorkflow >> apComputingMethods [
	^ apComputingMethods
]

{ #category : #dependencies }
APWorkflow >> apDataDependencies [
	^ apDataDependencies
]

{ #category : #dependencies }
APWorkflow >> apMake: aVariable dependencyOf: dependentVariable [
	(apDataDependencies at: dependentVariable ifAbsentPut: [ Set new ])
		add: aVariable
]

{ #category : #'data access' }
APWorkflow >> apObserveAllSlots [
	self class slots do:
		[ :slot | self apObserveSlot: slot name ]
]

{ #category : #'data access' }
APWorkflow >> apObserveSlot: aSymbol [
	self property: aSymbol
		  whenReadDo:
				[ self apReadAccessTo: aSymbol ].
	self property: aSymbol
		  whenChangedDo:
				[ :value | self apValueOf: aSymbol setTo: value ]
]

{ #category : #'data access' }
APWorkflow >> apReadAccessTo: aSymbol [
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
APWorkflow >> apValueOf: aSymbol setTo: aValue [
	| variables |
	variables := self apComputedVariablesInThisContext.
	variables ifEmpty: [ ^ self ].
	self assert: (variables includesKey: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]

{ #category : #serialization }
APWorkflow >> fuelAccept: aGeneralMapper [
	| slotContents methods |
	slotContents := Dictionary new.
	self class localSlots
		do: [ :slot |
				| valueHolder |
				valueHolder := slot rawRead: self.
				slotContents at: slot name
								 put: { valueHolder isValid.
										  valueHolder value.
										  valueHolder timeStamp } ].
	methods := self class workflowMethods
		collect: [ :method | method sourceCode ].

	^ aGeneralMapper
		visitSubstitution: self
		by: { slotContents. methods. apDataDependencies }
]

{ #category : #comparing }
APWorkflow >> hash [
	| instVarNames hash |
	instVarNames := self class instVarNames.
	hash := instVarNames hash.
	instVarNames do:
		[ :name |
			hash := hash bitXor: (self readSlotNamed: name) hash ].
	self class workflowMethods do:
		[ :method | hash bitXor: method sourceCode hash ].
	^ hash

]

{ #category : #initialization }
APWorkflow >> initialize [
	super initialize.
	self class initializeSlots: self.
	self apObserveAllSlots.
	self apClearCachedState.

]

{ #category : #dependencies }
APWorkflow >> restoreDataDependenciesTo: aDictionary [
	"Used only to restore dependencies from a serialized APDocument"
	apDataDependencies := aDictionary
]
