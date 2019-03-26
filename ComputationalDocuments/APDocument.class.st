Class {
	#name : #APDocument,
	#superclass : #Object,
	#traits : 'EqualityThroughVariables',
	#classTraits : 'EqualityThroughVariables classTrait',
	#instVars : [
		'name',
		'library',
		'data',
		'stories',
		'parsedStories',
		'gtDocuments'
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
	| slotContents methods dataDependencies |
	slotContents := data at: 1.
	methods := data at: 2.
	dataDependencies := data at: 3.
	data := APWorkflow name: name.
	slotContents keysDo:
		[ :slotName | data class addInstVarNamed: slotName asString ].
	slotContents keysAndValuesDo:
		[ :slotName :contents |
			| valueHolder |
			valueHolder := (data class slotNamed: slotName) rawRead: data.
			valueHolder restoreState: contents ].
	methods do: [ :each | data class compile: each ].
	data restoreDataDependenciesTo: dataDependencies
]

{ #category : #inspecting }
APDocument >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
					strategy: (APContainerStorageStrategy new container: self);
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
	parsedStories := Dictionary new.
	self parseStory: #Main.
	gtDocuments := Dictionary new.
	data := APWorkflow name: aSymbol
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
APDocument >> methodDefinitionFromString: aString [
	^ self data class methodNamed: aString asSymbol
]

{ #category : #accessing }
APDocument >> name [
	^ name
]

{ #category : #parsing }
APDocument >> parseStory: aSymbol [
	| parser |
	parser := PRPillarParser new optimize.
	parsedStories at: aSymbol
					  put: (parser parse: (stories at: aSymbol))
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

{ #category : #parsing }
APDocument >> scriptsInStories [
	| visitor |
	visitor := APCodeBlockVisitor new.
	parsedStories valuesDo:
		[ :parsedDocument | parsedDocument accept: visitor ].
	^ visitor labelledCodeBlocks
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
	stories at: aSymbol put: aString.
	self parseStory: aSymbol
]

{ #category : #inspecting }
APDocument >> workflowViewFor: aMondrian [
	| scriptsForData datasets inBox inRoundedBox edges |
	self data apCollectComputingMethods.
	scriptsForData := self data apComputingMethods.
	datasets := self datasets.
	inBox := [ :element |
					element padding: (BlInsets all: 8);
							  border: (BlBorder builder width: 1; paint: Color black; build) ].
	inRoundedBox := [ :element | (inBox value: element) geometry: (BlRectangle cornerRadius: 20) ].
	"The dataset nodes"
	aMondrian nodes
		shape:
			[ :x |
				| datasetName timeStamp |
				datasetName := x name asRopedText fontSize: 8.
				x isValid
					ifTrue: [ timeStamp := x timeStamp asRopedText fontSize: 6.
								 inRoundedBox value:
									(BlElement new
										layout: (BlLinearLayout vertical cellSpacing: 5);
										constraintsDo: [ :c | 
									     c horizontal fitContent.
									     c vertical fitContent ];
										addChildren:
											{ BlTextElement new text: datasetName.
											  BlTextElement new text: timeStamp }) ]
					ifFalse: [ datasetName foreground: Color red.
								  inRoundedBox value: (BlTextElement new text: datasetName)  ] ];
		with: datasets values.
	"The script nodes"
	aMondrian nodes
		shape:
			[ :x | inBox value: (BlTextElement new text: (x selector asRopedText fontSize: 8))];
		with: self scripts.
	edges := OrderedCollection new.
	"The edges from datasets to scripts"
	self data apDataDependencies
		keysAndValuesDo:
			[ :var :dependencies |
				| methodForVar |
				methodForVar := scriptsForData at: var.
				dependencies do:
					[ :each |
						edges add: { datasets at: each. methodForVar } ] ].
	"The edges from scripts to datasets"
	self scripts
		do: [ :each |
				each pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | edges add:
										{ each. self datasets at: p arguments first } ] ].
	"The greaphical representation of the edges"
	aMondrian edges
		shape: [ :x | 
			BlLineElement new
				toHead: (BlArrowheadSimpleArrow new
							border: (BlBorder paint: Color gray width: 1));
				border: (BlBorder paint: Color gray width: 1) ];
		fromCenterBottom;
		toCenterTop;
		connect: edges from: #first to: #second.

]
