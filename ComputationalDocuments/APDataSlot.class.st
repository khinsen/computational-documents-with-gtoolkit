Class {
	#name : #APDataSlot,
	#superclass : #ObservableSlot,
	#category : #ComputationalDocuments
}

{ #category : #initialization }
APDataSlot >> initialize: anObject [

	self rawWrite: (APValueHolder value: nil) to: anObject

]
