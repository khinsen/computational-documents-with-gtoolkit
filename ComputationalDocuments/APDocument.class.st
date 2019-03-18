Class {
	#name : #APDocument,
	#superclass : #Object,
	#traits : 'EqualityThroughVariables',
	#classTraits : 'EqualityThroughVariables classTrait',
	#instVars : [
		'name',
		'library',
		'data',
		'stories'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APDocument class >> fromFuelFile: aFuelFileReference [
	| document |
	document := aFuelFileReference
						binaryReadStreamDo:
							[ :stream |
									(FLMaterializer newDefault
										materializeFrom: stream) root ].
	self assert: (document isMemberOf: self).
	^ document
]

{ #category : #'fuel support' }
APDocument class >> fuelIgnoredInstanceVariableNames [
	^#(library)
]

{ #category : #'instance creation' }
APDocument class >> name: aSymbol [
	^self basicNew
			initializeWithName: aSymbol;
			yourself
]

{ #category : #accessing }
APDocument >> data [
	^ data
]

{ #category : #workflow }
APDocument >> datasetNamed: aSymbol [
	(self datasetNames includes: aSymbol)
		ifFalse: [ self error: 'No dataset named ', aSymbol ].
	^ data perform: aSymbol
]

{ #category : #workflow }
APDocument >> datasetNames [
	^ data class instVarNames

]

{ #category : #workflow }
APDocument >> datasets [
	"Return a dictionary mapping dataset names to APValueHolders"
	| d |
	d := Dictionary new.
	self datasetNames
		do: [ :dsName | d at: dsName put: (self data instVarNamed: dsName) ].
	^ d
]

{ #category : #workflow }
APDocument >> defineDatasetNamed: aSymbol [
	data class addInstVarNamed: aSymbol
]

{ #category : #workflow }
APDocument >> defineScript: aString [
	data class compile: aString
]

{ #category : #accessing }
APDocument >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ data
]

{ #category : #initialization }
APDocument >> fuelAfterMaterialization [
	| slotValues methods dataDependencies |
	slotValues := data at: 1.
	methods := data at: 2.
	dataDependencies := data at: 3.
	data := APWorkflow name: name.
	slotValues keysDo:
		[ :slotName | data class addInstVarNamed: slotName asString ].
	slotValues keysAndValuesDo:
		[ :slotName :value | (data class slotNamed: slotName) write: value to: data ].
	methods do: [ :each | data class compile: each ].
	data restoreDataDependenciesTo: dataDependencies
]

{ #category : #inspecting }
APDocument >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
					strategy: (GtContainerStorageStrategy new container: self);
					read. 
	^ (aDocument gtTextFor: aView)
		title: 'Description' translated;
		priority: -1;
		action: [ :anAction | 
			aDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #inspecting }
APDocument >> gtMethodsFor: aView [
	<gtView>
	^ aView explicit
		title: 'Methods' translated;
		priority: 2;
		stencil: [ (APWorkflowMethodsCoder forObject: self data) asElement ]
]

{ #category : #inspecting }
APDocument >> gtWorkflowViewFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Workflow' translated;
		priority: 1;
		painting:
			[ :view |
				self workflowViewFor: view.
				view layout custom: (GtGradVerticalDominanceTreeLayout new). ]
]

{ #category : #initialization }
APDocument >> initializeWithName: aSymbol [
	name := aSymbol.
	stories := Dictionary with: #Main -> ''.
	data := APWorkflow name: aSymbol.

]

{ #category : #comparing }
APDocument >> instVarsExcludedFromEquality [
	^#(library)

]

{ #category : #accessing }
APDocument >> library [
	^ library
]

{ #category : #accessing }
APDocument >> library: anAPLibrary [
	library := anAPLibrary
]

{ #category : #accessing }
APDocument >> name [
	^ name
]

{ #category : #printing }
APDocument >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	name printOn: aStream.
	aStream nextPut: $).
]

{ #category : #workflow }
APDocument >> runScript: aSymbol [
	data perform: aSymbol
]

{ #category : #workflow }
APDocument >> scriptNames [
	^ self scripts collect: #selector
]

{ #category : #workflow }
APDocument >> scripts [
	^ data class methods
		select: [ :each | (each pragmas collect: #selector) includes: #apComputes: ]

]

{ #category : #persistence }
APDocument >> store [
	library
		ifNotNil: [ library storeDocumentNamed: self name ]
		ifNil: [ self error: 'This document is not part of any library' ]
]

{ #category : #persistence }
APDocument >> storeInFile: aFileReference [
	aFileReference
		binaryWriteStreamDo:
			[ :stream | FLSerializer serialize: self on: stream ]

]

{ #category : #accessing }
APDocument >> storyNamed: aSymbol [
	^ stories at: aSymbol
]

{ #category : #accessing }
APDocument >> storyNamed: aSymbol text: aString [
	stories at: aSymbol put: aString
]

{ #category : #inspecting }
APDocument >> workflowViewFor: aView [
	| scriptsForData edges |
	self data apCollectComputingMethods.
	scriptsForData := self data apComputingMethods.
	aView nodes
		shape:
			[ :x |
				BlTextElement new
					text: x key asRopedText;
					padding:
						(BlInsets
							top: 5
							right: 5
							bottom: 5
							left: 5) ];
		with: self datasets associations.
	aView nodes
		shape:
			[ :x |
				BlTextElement new
					text: x selector asRopedText;
					padding:
						(BlInsets
							top: 5
							right: 5
							bottom: 5
							left: 5) ];
		with: self scripts.
	edges := OrderedCollection new.
	self data apDataDependencies
		keysAndValuesDo:
			[ :var :dependencies |
				| methodForVar |
				methodForVar := scriptsForData at: var.
				dependencies do:
					[ :each |
						edges add: { self datasets associationAt: each. methodForVar }.
						edges add: { methodForVar. self datasets associationAt: var } ] ].
	self scripts
		do: [ :each |
				each pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | edges add:
										{ each. self datasets associationAt: p arguments first } ] ].
	aView edges
		shape: [ :x | 
			BlLineElement new
				toHead: (BlArrowheadSimpleArrow new
							border: (BlBorder paint: Color gray width: 1));
				border: (BlBorder paint: Color gray width: 1) ];
		fromCenterBottom;
		toCenterTop;
		connect: edges from: #first to: #second.

]
