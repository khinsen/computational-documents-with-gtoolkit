Class {
	#name : #APWorkflowMethodCoder,
	#superclass : #GtMethodCoder,
	#category : #'ComputationalDocuments-Obsolete'
}

{ #category : #private }
APWorkflowMethodCoder >> compile [
	subCoders ifNotNil:
		[ subCoders
			do: [ :each | 
				each compile
					ifFalse: [ ^ false ] ] ].
	self classOrMetaClass compile: self newMethodSource.
	^ true
]
