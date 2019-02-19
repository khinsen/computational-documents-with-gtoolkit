Class {
	#name : #ComputationalDocument,
	#superclass : #Object,
	#instVars : [
		'story'
	],
	#category : #ComputationalDocuments
}

{ #category : #accessing }
ComputationalDocument >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ self
]

{ #category : #accessing }
ComputationalDocument >> gtDocumentFor: aView [
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
ComputationalDocument >> initialize [
	story := ''
]

{ #category : #accessing }
ComputationalDocument >> name [
	self subclassResponsibility
]

{ #category : #accessing }
ComputationalDocument >> story [
	^ story
]

{ #category : #accessing }
ComputationalDocument >> story: aString [
	story := aString
]
