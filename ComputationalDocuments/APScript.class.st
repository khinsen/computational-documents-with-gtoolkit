Class {
	#name : #APScript,
	#superclass : #Object,
	#instVars : [
		'sourceCode',
		'workflow'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APScript class >> workflow: aWorkflow [
	^self basicNew
		initializeWithWorkflow: aWorkflow;
		yourself
]

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

{ #category : #initialization }
APScript >> initializeWithWorkflow: aWorkflow [
	workflow := aWorkflow.
	sourceCode := ''.
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
