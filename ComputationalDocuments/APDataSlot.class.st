Class {
	#name : #APDataSlot,
	#superclass : #ObservableSlot,
	#category : #'ComputationalDocuments-Slots'
}

{ #category : #initialization }
APDataSlot >> initialize: anObject [

	self rawWrite: (APValueHolder value: nil) to: anObject

]
