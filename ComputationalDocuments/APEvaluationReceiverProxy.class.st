"
I am a proxy object that wraps the evaluationReceiver in a PRCodeblock. My only purpose is to redefine #gtViewsFor:inContext: in such a way that a return value of self is made invisible in a Gt2Document.
"
Class {
	#name : #APEvaluationReceiverProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'receiver'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APEvaluationReceiverProxy class >> receiver: anObject [
	^self basicNew
			initializeWithReceiver: anObject;
			yourself
]

{ #category : #'reflective operations' }
APEvaluationReceiverProxy >> doesNotUnderstand: aMessage [
	| result |
	result := receiver perform: aMessage selector withArguments: aMessage arguments.
	result == receiver ifTrue: [ ^ self ].
	^ result

]

{ #category : #inspecting }
APEvaluationReceiverProxy >> gtViewsFor: aView inContext: aContext [
	^ aView explicit
		stencil: [ BlElement new padding: (BlInsets all: 1); background: (Color gray) ]
	"^ receiver gtViewsFor: aView inContext: aContext"
]

{ #category : #initialization }
APEvaluationReceiverProxy >> initializeWithReceiver: anObject [
	self initialize.
	receiver := anObject
]
