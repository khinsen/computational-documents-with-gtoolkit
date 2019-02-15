"
I am a data slot in an ActivePaper. Read and write access are verified and logged to define the dependence graph.
"
Class {
	#name : #APDataSlot,
	#superclass : #InstanceVariableSlot,
	#category : #ComputationalDocuments
}

{ #category : #initialization }
APDataSlot >> initialize: anObject [
	super write: nil to: anObject
]

{ #category : #accessing }
APDataSlot >> read: anObject [
	anObject announceReadAccessTo: name.
	^ super read: anObject
]

{ #category : #accessing }
APDataSlot >> write: aValue to: anObject [
	anObject announceWriteAccessTo: name.
	^ super write: aValue to: anObject

]
