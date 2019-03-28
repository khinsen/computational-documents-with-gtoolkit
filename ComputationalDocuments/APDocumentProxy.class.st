Class {
	#name : #APDocumentProxy,
	#superclass : #Object,
	#traits : 'EqualityThroughVariables',
	#classTraits : 'EqualityThroughVariables classTrait',
	#instVars : [
		'name',
		'library',
		'document'
	],
	#category : #'ComputationalDocuments-Obsolete'
}

{ #category : #'instance creation' }
APDocumentProxy class >> name: aSymbol library: anAPLibrary [
	^self basicNew
			initializeWithName: aSymbol library: anAPLibrary;
			yourself
]

{ #category : #'reflective operations' }
APDocumentProxy >> doesNotUnderstand: aMessage [
	document ifNil: [ document := library documentNamed: name ].
	^ document perform: aMessage selector withArguments: aMessage arguments

]

{ #category : #initialization }
APDocumentProxy >> initializeWithName: aSymbol library: anAPLibrary [
	name := aSymbol.
	library := anAPLibrary.
	document := nil
]
