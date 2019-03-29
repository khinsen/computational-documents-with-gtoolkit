Class {
	#name : #APScript,
	#superclass : #Object,
	#instVars : [
		'name',
		'sourceCode',
		'workflow'
	],
	#category : #ComputationalDocuments
}

{ #category : #evaluating }
APScript >> compile [
	^ self workflow class compiler
		source: self sourceCode;
		receiver: self workflow;
		compile
]

{ #category : #evaluating }
APScript >> evaluate [
	self workflow class compiler
		source: self sourceCode;
		receiver: self workflow;
		evaluate
]

{ #category : #inspecting }
APScript >> gtSourceFor: aView [
	<gtView>
	^ aView explicit
		title: self name;
		priority: 10;
		stencil: [ (GtPharoSnippetCoder new
							source: self sourceCode;
							yourself)
						expanded: true;
						asElement ]
	

]

{ #category : #initialization }
APScript >> initialize [
	sourceCode := ''.
]

{ #category : #accessing }
APScript >> name [
	^ name
]

{ #category : #accessing }
APScript >> name: aSymbol [
	name := aSymbol
]

{ #category : #accessing }
APScript >> sourceCode [
	^ sourceCode
]

{ #category : #accessing }
APScript >> sourceCode: aString [
	sourceCode := aString
]

{ #category : #accessing }
APScript >> workflow [
	^ workflow
]

{ #category : #accessing }
APScript >> workflow: aWorkflow [
	workflow := aWorkflow
]
