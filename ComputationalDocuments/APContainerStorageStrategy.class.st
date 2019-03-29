Class {
	#name : #APContainerStorageStrategy,
	#superclass : #GtStorageStrategy,
	#instVars : [
		'container'
	],
	#category : #'ComputationalDocuments-GToolkit'
}

{ #category : #accessing }
APContainerStorageStrategy >> basename [
	"Return a string representing the document filename"
	<return: #String>
	^ self name, '.', GtFileUtilityConstants pillarExtension
]

{ #category : #accessing }
APContainerStorageStrategy >> container [
	^ container
]

{ #category : #accessing }
APContainerStorageStrategy >> container: aContainer [
	container := aContainer
]

{ #category : #accessing }
APContainerStorageStrategy >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ self container evaluationReceiver
]

{ #category : #testing }
APContainerStorageStrategy >> exists [
	<return: #Boolean>
	^ self container isNotNil
]

{ #category : #accessing }
APContainerStorageStrategy >> methodDefinitionFromString: aString [
	^ self container methodDefinitionFromString: aString
]

{ #category : #accessing }
APContainerStorageStrategy >> name [
	"Return a string representing the stored document"
	<return: #String>
	^ self container name
]

{ #category : #actions }
APContainerStorageStrategy >> read: aGtDocument [ 
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	aGtDocument text: (self container storyNamed: #Main)
]

{ #category : #accessing }
APContainerStorageStrategy >> rootDirectory [
	<return: #FileReference>
	^ FileSystem workingDirectory
]

{ #category : #accessing }
APContainerStorageStrategy >> scriptNamed: aSymbol [
	^ self container scriptNamed: aSymbol
]

{ #category : #actions }
APContainerStorageStrategy >> store: aGtDocument [
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	self container storyNamed: #Main text: aGtDocument text asString.
	self container store
	
]
