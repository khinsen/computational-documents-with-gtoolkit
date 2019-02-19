Class {
	#name : #Gt2ContainerStorageStrategy,
	#superclass : #Gt2StorageStrategy,
	#instVars : [
		'container'
	],
	#category : #ComputationalDocuments
}

{ #category : #accessing }
Gt2ContainerStorageStrategy >> basename [
	"Return a string representing the document filename"
	<return: #String>
	^ self name, '.', GtFileUtilityConstants pillarExtension
]

{ #category : #accessing }
Gt2ContainerStorageStrategy >> container [
	^ container
]

{ #category : #accessing }
Gt2ContainerStorageStrategy >> container: aContainer [
	container := aContainer
]

{ #category : #accessing }
Gt2ContainerStorageStrategy >> evaluationReceiver [
	"Return an object that is used as a receiver (self) in a codeblock (code snippet) evalution"
	<return: #Object>
	^ self container evaluationReceiver
]

{ #category : #testing }
Gt2ContainerStorageStrategy >> exists [
	<return: #Boolean>
	^ self container isNotNil
]

{ #category : #accessing }
Gt2ContainerStorageStrategy >> name [
	"Return a string representing the stored document"
	<return: #String>
	^ self container name
]

{ #category : #actions }
Gt2ContainerStorageStrategy >> read: aGt2Document [ 
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	aGt2Document text: self container story
]

{ #category : #accessing }
Gt2ContainerStorageStrategy >> rootDirectory [
	<return: #FileReference>
	^ FileSystem workingDirectory
]

{ #category : #actions }
Gt2ContainerStorageStrategy >> store: aGt2Document [
	self 
		assert: [ self container notNil ]
		description: [ 'Container must be non-nil to store a document there' ].
	self container story: aGt2Document text asString
	
]
