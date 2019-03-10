Class {
	#name : #GtContainerStorageStrategy,
	#superclass : #GtStorageStrategy,
	#instVars : [
		'container'
	],
	#category : #'ComputationalDocuments-GToolkit'
}

{ #category : #accessing }
GtContainerStorageStrategy >> basename [
	"Return a string representing the document filename"
	<return: #String>
	^ self name, '.', GtFileUtilityConstants pillarExtension
]

{ #category : #accessing }
GtContainerStorageStrategy >> container [
	^ container
]

{ #category : #accessing }
GtContainerStorageStrategy >> container: aContainer [
	container := aContainer
]

{ #category : #accessing }
GtContainerStorageStrategy >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ self container evaluationReceiver
]

{ #category : #testing }
GtContainerStorageStrategy >> exists [
	<return: #Boolean>
	^ self container isNotNil
]

{ #category : #accessing }
GtContainerStorageStrategy >> name [
	"Return a string representing the stored document"
	<return: #String>
	^ self container name
]

{ #category : #actions }
GtContainerStorageStrategy >> read: aGtDocument [ 
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	aGtDocument text: self container storyNamed: #Main
]

{ #category : #accessing }
GtContainerStorageStrategy >> rootDirectory [
	<return: #FileReference>
	^ FileSystem workingDirectory
]

{ #category : #actions }
GtContainerStorageStrategy >> store: aGtDocument [
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	self container storyNamed: #Main text: aGtDocument text asString
	
]
