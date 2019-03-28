Class {
	#name : #APDataSlot,
	#superclass : #ObservableSlot,
	#category : #'ComputationalDocuments-Slots'
}

{ #category : #initialization }
APDataSlot >> initialize: anObject [

	(self rawRead: anObject)
		ifNil: [self rawWrite: (APValueHolder new name: name) to: anObject]

]
