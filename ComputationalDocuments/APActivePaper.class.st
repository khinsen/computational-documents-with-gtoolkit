Class {
	#name : #APActivePaper,
	#superclass : #Object,
	#traits : 'TAPData + TAPWiki + TSingleton',
	#classTraits : 'TAPData classTrait + TAPWiki classTrait + TSingleton classTrait',
	#instVars : [
		'apDataDependencies'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance variables' }
APActivePaper class >> addInstVarNamed: aString [
	"Override instance variable creation to make read and write access to all
	instance variables observable. Notify the uniqueInstance of every change."

	| newInstVarNames |

	"Apply special treatment only to subclasses"
	self isAbstract
		ifTrue: [ ^ super addInstVarNamed: aString ].

	newInstVarNames := aString substrings.
	newInstVarNames ifEmpty: [ ^ self ].

	"Replace all new instance variables by APDataSlots"
	newInstVarNames do: [ :each |
		| varSymbol |
		varSymbol := each asSymbol.
		self addSlot: (APDataSlot named: varSymbol).
		self compile: each , ' self apCompute: #', each, '. ^ ', each classified: 'generated' ].

	"Invalidate cached state and put the new slot(s) under observation"
	self allInstancesDo:
		[ :each |
			self initializeSlots: each.
			each apClearCachedState.
			each apObserveAllSlots ].

]

{ #category : #inspecting }
APActivePaper class >> boxAround: aBlElement [
	"Add a rectangular box with some padding to a BlElement.
	 Used for script nodes in a workflow."
	^ aBlElement padding: (BlInsets all: 8);
				 border: (BlBorder builder width: 1; paint: Color black; build)

]

{ #category : #workflow }
APActivePaper class >> dataSlotNames [
	^ self dataSlots collect: #name.
]

{ #category : #workflow }
APActivePaper class >> dataSlots [
	^ self slots select: [ :s | s isKindOf: APDataSlot ]
]

{ #category : #workflow }
APActivePaper class >> datasets [
	"Return a dictionary mapping dataset names to corresponding APValueHolders"
	| instance datasets |
	instance := self uniqueInstance.
	datasets := Dictionary new.
	self dataSlots do: [ :s | datasets at: s name put: (s rawRead: instance) ].
	^ datasets
]

{ #category : #inspecting }
APActivePaper class >> gtWorkflowViewFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Workflow' translated;
		priority: -5;
		painting:
			[ :view |
				self workflowViewFor: view.
				view layout custom: (GtGradVerticalDominanceTreeLayout new). ]
]

{ #category : #testing }
APActivePaper class >> isAbstract [
	^ true
]

{ #category : #'instance creation' }
APActivePaper class >> name: aSymbol [
	| newClass |
	self isAbstract
		ifFalse: "self is a subclass of APActivePaper"
			[ ^ self error: 'Instances are created using ''APActivePaper name: aSymbol''' ].
	newClass := self subclass: aSymbol
					  instanceVariableNames: ''
					  classVariableNames: ''
					  package: self package name.
	newClass class compile: 'isAbstract ^ false'
						classified: 'testing'.
	^ newClass
]

{ #category : #'instance variables' }
APActivePaper class >> removeInstVarNamed: aString [

	"Invalidate cached state and put the new slot(s) under observation"
	self allInstancesDo: [ :each | each apClearCachedState ].

	"Remove the auto-generated accessor method"
	self removeSelector: aString asSymbol.

	"Remove the slot"
	^ super removeInstVarNamed: aString.

]

{ #category : #inspecting }
APActivePaper class >> roundedBoxAround: aBlElement [
	"Add a box with rounded corners plus some padding to a BlElement.
	 Used for dataset nodes in a workflow."
	^ (self boxAround: aBlElement)
		geometry: (BlRectangle cornerRadius: 20);
		yourself

]

{ #category : #dependencies }
APActivePaper class >> scripts [
	| scripts uncomputedDatasets computedUndeclaredDatasets |
	scripts := Dictionary new.
	(Pragma allNamed: #computes: in: self) do:
		[ :each |
			each method numArgs > 0
				ifTrue: [ Error signal: 'Method ', each method name,
													' computes ', each arguments first,
													' but requires arguments' ].
			scripts at: each arguments first
				ifPresent: [ :earlier |
								  Error signal: 'Methods ', each method name,
														' and ', earlier method name,
														' both claim to compute ',
														each arguments first ]
				ifAbsentPut: [ each method ] ].
	computedUndeclaredDatasets := scripts keys difference: self dataSlotNames.
	computedUndeclaredDatasets ifNotEmpty: [ Error signal: 'Variables computed but not declared: ',
																		 (', ' join: computedUndeclaredDatasets) ].
	uncomputedDatasets := self dataSlotNames difference: scripts keys.
	uncomputedDatasets ifNotEmpty: [ Error signal: 'Variables declared but not computed: ',
																	 (', ' join: uncomputedDatasets) ].
	^ scripts
]

{ #category : #accessing }
APActivePaper class >> wikiEvaluationReceiverForPage: aSymbol [
	^ self uniqueInstance
]

{ #category : #inspecting }
APActivePaper class >> workflowArrow [
	"Make an arrow for use in a workflow"
	^ BlLineElement new
			toHead: (BlArrowheadSimpleArrow new
						border: (BlBorder paint: Color gray width: 1));
			border: (BlBorder paint: Color gray width: 1)
]

{ #category : #workflow }
APActivePaper class >> workflowMethods [
	^ self methods select: [ :each | each protocol ~= 'generated' and: [ each selector ~= #initialize ] ]
]

{ #category : #inspecting }
APActivePaper class >> workflowNodeForDataset: anAPValueHolder [
	"Answer a BlElement representing a dataset node in a workflow."
	| datasetName timeStamp nodeElement |
	datasetName := anAPValueHolder name asRopedText fontSize: 8.
	anAPValueHolder isValid
		ifTrue: [ timeStamp := ((anAPValueHolder timeStamp printString first: 16)
											replaceAll: $T with: Character space)
											asRopedText fontSize: 6.
					 nodeElement := BlElement new
							layout: (BlLinearLayout vertical cellSpacing: 5);
							constraintsDo: [ :c | 
						     c horizontal fitContent.
						     c vertical fitContent ];
							addChildren:
								{ BlTextElement new text: datasetName.
								  BlTextElement new text: timeStamp } ]
		ifFalse: [ datasetName foreground: Color red.
					  nodeElement := BlTextElement new text: datasetName  ].
	^ self roundedBoxAround: nodeElement.
]

{ #category : #inspecting }
APActivePaper class >> workflowNodeForScript: aCompiledMethod [
	"Answer a BlElement representing a script in a workflow"
	^ self boxAround:
		(BlTextElement new text:
			 (aCompiledMethod selector asRopedText fontSize: 8))

]

{ #category : #inspecting }
APActivePaper class >> workflowViewFor: aMondrian [
	"Add the graphics elements of a workflow view to a GtMondrian"
	| scripts datasets edges |
	scripts := self scripts.
	datasets := self datasets.
	"The dataset nodes"
	aMondrian nodes
		shape: [ :each | self workflowNodeForDataset: each ];
		with: datasets values.
	"The script nodes"
	aMondrian nodes
		shape: [ :each | self workflowNodeForScript: each ];
		with: scripts values asIdentitySet.
	edges := OrderedCollection new.
	"The edges from datasets to scripts"
	self uniqueInstance apDataDependencies
		keysAndValuesDo:
			[ :var :dependencies |
				dependencies do:
					[ :each |
						edges add: { datasets at: each.
										 scripts at: var } ] ].
	"The edges from scripts to datasets"
	scripts
		keysAndValuesDo:
			[ :dataSetName :script |
			 	edges add: {script. datasets at: dataSetName } ].
	"The graphical representation of the edges"
	aMondrian edges
		shape: [ :x | self workflowArrow ];
		fromCenterBottom;
		toCenterTop;
		connect: edges from: #first to: #second.

]

{ #category : #dependencies }
APActivePaper >> apClearCachedState [
	apDataDependencies := Dictionary new.

]

{ #category : #computation }
APActivePaper >> apCompute: aSymbol [
	"If the slot holds a valid value, do nothing."
	(self apValueHolderFor: aSymbol) isValid ifTrue: [ ^ self ]. 
	(self class scripts at: aSymbol)
		valueWithReceiver: self arguments: Array new

]

{ #category : #dependencies }
APActivePaper >> apDataDependencies [
	^ apDataDependencies
]

{ #category : #computation }
APActivePaper >> apDatasetsComputedInThisContext [
	"Look for scripts in the execution context and record the datasets they compute.
	 Answer a dictionary mapping dataset names to the level in the call stack at which
	 their script was found."
	| computedDatasets level context |
	computedDatasets := Dictionary new.
	level := 1.
	context := thisContext.
	[ context isNil ] whileFalse:
		[ context := context findContextSuchThat:
			[ :c | c methodClass = self class ].
		  context ifNotNil:
			[ context method pragmas
					select: [ :p | p selector = #computes: ]
					thenDo: [ :p | computedDatasets at: p arguments first ifAbsentPut: level ].
			  context := context sender.
			  level := level + 1 ] ].
	^ computedDatasets
]

{ #category : #dependencies }
APActivePaper >> apMake: aVariable dependencyOf: dependentVariable [
	(apDataDependencies at: dependentVariable ifAbsentPut: [ Set new ])
		add: aVariable
]

{ #category : #'data access' }
APActivePaper >> apObserveAllSlots [
	self class dataSlots do:
		[ :slot | self apObserveDataSlot: slot name ]
]

{ #category : #'data access' }
APActivePaper >> apObserveDataSlot: aSymbol [
	self property: aSymbol
		  whenReadDo:
				[ self apProcessReadAccessTo: aSymbol ].
	self property: aSymbol
		  whenChangedDo:
				[ :value | self apProcessChangeOf: aSymbol newValue: value ]
]

{ #category : #'data access' }
APActivePaper >> apProcessChangeOf: aSymbol newValue: aValue [
	| variables |
	variables := self apDatasetsComputedInThisContext.
	variables ifEmpty: [ ^ self ].
	self assert: (variables includesKey: aSymbol)
		  description: 'Unauthorized attempt to modify variable ' , aSymbol asString.

]

{ #category : #'data access' }
APActivePaper >> apProcessReadAccessTo: aSymbol [
	| variables |
	variables := self apDatasetsComputedInThisContext.
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
APActivePaper >> apValueHolderFor: aSymbol [
	^ (self class slotNamed: aSymbol) rawRead: self
]

{ #category : #initialization }
APActivePaper >> initialize [
	super initialize.
	self class initializeSlots: self.
	self apObserveAllSlots.
	self apClearCachedState.

]

{ #category : #dependencies }
APActivePaper >> restoreDataDependenciesTo: aDictionary [
	"Used only to restore dependencies from a serialized APDocument"
	apDataDependencies := aDictionary
]
