Trait {
	#name : #TAPData,
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#category : #'ComputationalDocuments-Slots'
}

{ #category : #events }
TAPData >> notifyPropertyRead: aName [

	(self observablePropertyNamed: aName) valueRead
]

{ #category : #events }
TAPData >> property: aName whenReadDo: aBlockClosure [ 
	
	"Obtain the raw value.
	We need to access the underlying value holder to subscribe to it"
	(self observablePropertyNamed: aName) whenReadDo: aBlockClosure
]
