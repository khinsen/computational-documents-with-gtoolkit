Class {
	#name : #APWorkflowMethodsCoder,
	#superclass : #GtClassMethodsCoder,
	#category : #ComputationalDocuments
}

{ #category : #actions }
APWorkflowMethodsCoder >> addNewCoder [
	| coder |
	coder := APWorkflowMethodCoder newMethod.
	coder classOrMetaClass: self newMethodClass.
	coder object: self object.
	methodCoders addFirst: coder.
	self announce: (GtMethodCoderAdded new coder: self; methodCoder: coder)
]

{ #category : #'event handling' }
APWorkflowMethodsCoder >> methodAdded: aValueAdded [
	| coder |
	coder := APWorkflowMethodCoder forMethod: aValueAdded newValue.
	methodCoders add: coder.
	self announce: (GtMethodCoderAdded new coder: self; methodCoder: coder)
]

{ #category : #private }
APWorkflowMethodsCoder >> newMethodCoderFor: aMethod [
	| coder |
	coder := APWorkflowMethodCoder forMethod: aMethod.
	coder methodsCoder: self.
	^ coder
]
