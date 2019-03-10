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
	^ APEvaluationReceiverProxy receiver: self
]

{ #category : #accessing }
ComputationalDocument >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
					strategy: (GtContainerStorageStrategy new container: self);
					read. 
	^ (aDocument gtTextFor: aView)
		title: 'Story';
		priority: -1;
		action: [ :anAction | 
			aDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #inspecting }
ComputationalDocument >> gtViewsFor: aView inContext: aContext [
	| view |
	view := super gtViewsFor: aView inContext: aContext.
	"Returns a GtPhlowLabelledView"
	^ view
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
