Class {
	#name : #APScriptDocument,
	#superclass : #Object,
	#traits : 'EqualityThroughVariables',
	#classTraits : 'EqualityThroughVariables classTrait',
	#instVars : [
		'name',
		'library',
		'data',
		'stories',
		'parsedStories',
		'scripts'
	],
	#category : #'ComputationalDocuments-scriptBased'
}

{ #category : #'instance creation' }
APScriptDocument class >> fromFuelFile: aFuelFileReference [
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
APScriptDocument class >> fuelIgnoredInstanceVariableNames [
	^#(library)
]

{ #category : #'instance creation' }
APScriptDocument class >> name: aSymbol [
	^self basicNew
			initializeWithName: aSymbol;
			yourself
]

{ #category : #workflow }
APScriptDocument >> addScript: aScript [
	self data addScript: aScript
]

{ #category : #inspecting }
APScriptDocument >> asGtDocument [
	^ GtDocument new
					 strategy: (APContainerStorageStrategy new container: self);
					 read
]

{ #category : #accessing }
APScriptDocument >> data [
	^ data
]

{ #category : #workflow }
APScriptDocument >> datasetNamed: aSymbol [
	(self datasetNames includes: aSymbol)
		ifFalse: [ self error: 'No dataset named ', aSymbol ].
	^ data perform: aSymbol
]

{ #category : #workflow }
APScriptDocument >> datasetNames [
	^ data class instVarNames

]

{ #category : #workflow }
APScriptDocument >> datasets [
	"Return a dictionary mapping dataset names to APValueHolders"
	| d |
	d := Dictionary new.
	self datasetNames
		do: [ :dsName | d at: dsName put: (self data instVarNamed: dsName) ].
	^ d
]

{ #category : #workflow }
APScriptDocument >> defineDatasetNamed: aSymbol [
	data class addInstVarNamed: aSymbol
]

{ #category : #workflow }
APScriptDocument >> defineScript: aString [
	data class compile: aString
]

{ #category : #accessing }
APScriptDocument >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ data
]

{ #category : #initialization }
APScriptDocument >> fuelAfterMaterialization [
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
APScriptDocument >> gtDocumentFor: aView [
	<gtView>
	| aGtDocument |
	aGtDocument := self asGtDocument.
	^ (aGtDocument gtTextFor: aView)
		title: 'Main page' translated;
		priority: -1;
		action: [ :anAction | 
			aGtDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aGtDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #inspecting }
APScriptDocument >> gtWorkflowViewFor: aView [
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
APScriptDocument >> initializeWithName: aSymbol [
	name := aSymbol.
	stories := Dictionary with: #Main -> ''.
	parsedStories := Dictionary new.
	self parseStory: #Main.
	data := APScriptWorkflow name: aSymbol
]

{ #category : #comparing }
APScriptDocument >> instVarsExcludedFromEquality [
	^#(library)

]

{ #category : #accessing }
APScriptDocument >> library [
	^ library
]

{ #category : #accessing }
APScriptDocument >> library: anAPLibrary [
	library := anAPLibrary
]

{ #category : #accessing }
APScriptDocument >> name [
	^ name
]

{ #category : #parsing }
APScriptDocument >> parseStory: aSymbol [
	| parser |
	parser := PRPillarParser new optimize.
	parsedStories at: aSymbol
					  put: (parser parse: (stories at: aSymbol))
]

{ #category : #printing }
APScriptDocument >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	name printOn: aStream.
	aStream nextPut: $).
]

{ #category : #workflow }
APScriptDocument >> runScript: aSymbol [
	(self scriptNamed: aSymbol) evaluate
]

{ #category : #workflow }
APScriptDocument >> scriptNamed: aSymbol [
	^ self data scriptNamed: aSymbol
]

{ #category : #workflow }
APScriptDocument >> scriptNames [
	^ self scripts collect: #name
]

{ #category : #workflow }
APScriptDocument >> scripts [
	^ data scripts
]

{ #category : #parsing }
APScriptDocument >> scriptsInStories [
	| visitor |
	visitor := APCodeBlockVisitor new.
	parsedStories valuesDo:
		[ :parsedDocument | parsedDocument accept: visitor ].
	^ visitor labelledCodeBlocks
]

{ #category : #workflow }
APScriptDocument >> setDatasetNamed: aSymbol to: aValue [
	(self valueHolderForDatasetNamed: aSymbol)
		value: aValue
]

{ #category : #persistence }
APScriptDocument >> store [
	library
		ifNotNil: [ library storeDocumentNamed: self name ]
		ifNil: [ self error: 'This document is not part of any library' ]
]

{ #category : #persistence }
APScriptDocument >> storeInFile: aFileReference [
	aFileReference
		binaryWriteStreamDo:
			[ :stream | FLSerializer serialize: self on: stream ]

]

{ #category : #accessing }
APScriptDocument >> storyNamed: aSymbol [
	^ stories at: aSymbol
]

{ #category : #accessing }
APScriptDocument >> storyNamed: aSymbol text: aString [
	stories at: aSymbol put: aString.
	self parseStory: aSymbol
]

{ #category : #workflow }
APScriptDocument >> valueHolderForDatasetNamed: aSymbol [
	(self datasetNames includes: aSymbol)
		ifFalse: [ self error: 'No dataset named ', aSymbol ].
	^ data apValueHolderFor: aSymbol
]

{ #category : #inspecting }
APScriptDocument >> workflowViewFor: aMondrian [
	| datasets inBox inRoundedBox edges |
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
			[ :x | inBox value: (BlTextElement new text: (x name asRopedText fontSize: 8))];
		with: self scripts.
	edges := OrderedCollection new.
	"The edges from datasets to scripts"
"	self data apDataDependencies
		keysAndValuesDo:
			[ :var :dependencies |
				| methodForVar |
				methodForVar := scriptsForData at: var.
				dependencies do:
					[ :each |
						edges add: { datasets at: each. methodForVar } ] ].
"	"The edges from scripts to datasets"
"	self scripts
		do: [ :each |
				each pragmas
					select: [ :p | p selector = #apComputes: ]
					thenDo: [ :p | edges add:
										{ each. self datasets at: p arguments first } ] ].
"	"The greaphical representation of the edges"
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
