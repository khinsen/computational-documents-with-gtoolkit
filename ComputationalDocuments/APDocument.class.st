Class {
	#name : #APDocument,
	#superclass : #Object,
	#instVars : [
		'story',
		'workflow',
		'name'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APDocument class >> name: aSymbol [
	^self basicNew
			initializeWithName: aSymbol;
			yourself
]

{ #category : #workflow }
APDocument >> datasetNamed: aSymbol [
	(self datasetNames includes: aSymbol)
		ifFalse: [ self error: 'No dataset named ', aSymbol ].
	^ workflow perform: aSymbol
]

{ #category : #workflow }
APDocument >> datasetNames [
	^ workflow class instVarNames asSet
]

{ #category : #workflow }
APDocument >> defineDatasetNamed: aSymbol [
	workflow class addInstVarNamed: aSymbol
]

{ #category : #workflow }
APDocument >> defineScript: aString [
	workflow class compile: aString
]

{ #category : #accessing }
APDocument >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ workflow
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
	story := ''.
	workflow := APWorkflow new.

]

{ #category : #accessing }
APDocument >> name [
	^ name
]

{ #category : #workflow }
APDocument >> runScript: aSymbol [
	workflow perform: aSymbol
]

{ #category : #workflow }
APDocument >> scriptNames [
	^ ((Pragma allNamed: #apComputes: in: workflow class)
			collect: [ :each | each method selector ])
		asSet

]

{ #category : #accessing }
APDocument >> story [
	^ story
]

{ #category : #accessing }
APDocument >> story: aString [
	story := aString
]
