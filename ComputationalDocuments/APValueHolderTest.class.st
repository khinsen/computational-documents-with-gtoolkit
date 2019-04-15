Class {
	#name : #APValueHolderTest,
	#superclass : #TestCase,
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #tests }
APValueHolderTest >> testChange [
	| valueHolder time fired |
	time := DateAndTime now.
	valueHolder := APValueHolder new.
	self deny: valueHolder isValid.

	valueHolder name: #foo.
	self assert: valueHolder name = #foo.

	valueHolder value: 'word'.
	self assert: valueHolder isValid.
	self assert: valueHolder value equals: 'word'.
	self assert: valueHolder timeStamp >= time.
	self assert: valueHolder timeStamp <= DateAndTime now.

	valueHolder invalidate.
	self deny: valueHolder isValid.

	fired := false.
	valueHolder whenChangedDo: [ fired := true ].
	valueHolder value: 'new'.
	self assert: valueHolder isValid.
	self assert: fired.
	self assert: valueHolder value equals: 'new'
]

{ #category : #tests }
APValueHolderTest >> testRead [
	| valueHolder fired |
	valueHolder := APValueHolder value: 'word'.
	self assert: valueHolder value equals: 'word'.
	fired := false.
	valueHolder whenReadDo: [ fired := true ].
	self assert: valueHolder value equals: 'word'.
	self assert: fired.

]

{ #category : #tests }
APValueHolderTest >> testValuesInBlockAfterChange [
	| valueHolder old new ann |
	valueHolder := APValueHolder value: 'old'.
	valueHolder
		whenChangedDo: [ :newValue :oldValue :a | 
			new := newValue.
			old := oldValue.
			ann := a ].
	valueHolder value: 'new'.
	self assert: old equals: 'old'.
	self assert: new equals: 'new'.
	self assert: (ann isMemberOf: ValueChanged)
]

{ #category : #tests }
APValueHolderTest >> testValuesInBlockAfterRead [
	| valueHolder heldValue ann |
	valueHolder := APValueHolder value: 'word'.
	valueHolder
		whenReadDo: [ :value :a | 
			heldValue := value.
			ann := a ].
	self assert: valueHolder value equals: 'word'.
	self assert: heldValue equals: 'word'.
	self assert: (ann isMemberOf: APValueRead)
]
