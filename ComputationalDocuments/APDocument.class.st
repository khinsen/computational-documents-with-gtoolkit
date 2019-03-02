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
	workflow := APDynamicWorkflow new.

]

{ #category : #accessing }
APDocument >> name [
	^ name
]

{ #category : #accessing }
APDocument >> story [
	^ story
]

{ #category : #accessing }
APDocument >> story: aString [
	story := aString
]
