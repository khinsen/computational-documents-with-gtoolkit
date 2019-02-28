Extension { #name : #ObservableSlot }

{ #category : #'*ComputationalDocuments' }
ObservableSlot >> rawRead: anObject [

	^ super read: anObject
]

{ #category : #'*ComputationalDocuments' }
ObservableSlot >> rawWrite: aValue to: anObject [

	^ super write: aValue to: anObject

]
