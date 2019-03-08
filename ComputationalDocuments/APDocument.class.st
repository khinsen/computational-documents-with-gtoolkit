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
	^ data class instVarNames asSet
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
	| slotValues methods |
	slotValues := data at: 1.
	methods := data at: 2.
	data := APWorkflow new.
	slotValues keysDo:
		[ :slotName | data class addInstVarNamed: slotName asString ].
	slotValues keysAndValuesDo:
		[ :slotName :value | (data class slotNamed: slotName) write: value to: data ].
	methods do: [ :each | data class compile: each ]
]

{ #category : #accessing }
APDocument >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := Gt2Document new
					strategy: (Gt2ContainerStorageStrategy new container: self);
					read. 
	^ (aDocument gtTextFor: aView)
		title: 'Story';
		priority: -1;
		action: [ :anAction | 
			aDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #initialization }
APDocument >> initializeWithName: aSymbol [
	name := aSymbol.
	stories := ''.
	data := APWorkflow new.

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

{ #category : #workflow }
APDocument >> runScript: aSymbol [
	data perform: aSymbol
]

{ #category : #workflow }
APDocument >> scriptNames [
	^ ((Pragma allNamed: #apComputes: in: data class)
			collect: [ :each | each method selector ])
		asSet

]

{ #category : #persistence }
APDocument >> store [
	library
		ifNotNil: [ library storeDocumentNamed: self name ]
		ifNil: [ self error: 'This document is not part of any library' ]
]

{ #category : #accessing }
APDocument >> storyNamed: aSymbol [
	^ stories at: aSymbol
]

{ #category : #accessing }
APDocument >> storyNamed: aSymbol text: aString [
	stories at: aSymbol put: aString
]
