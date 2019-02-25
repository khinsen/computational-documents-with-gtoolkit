Class {
	#name : #APValueHolder,
	#superclass : #NewValueHolder,
	#category : #ComputationalDocuments
}

{ #category : #accessing }
APValueHolder >> value [

	self valueRead.
	^ value
]

{ #category : #accessing }
APValueHolder >> valueRead [
	
	self announcer announce: (APValueRead value: value)
]

{ #category : #announcing }
APValueHolder >> whenReadDo: aBlock [
	"Culled block [ :value :announcement :announcer | ]"

	| block |
	block := [ :announcement :ann | 
	aBlock
		cull: announcement value
		cull: announcement
		cull: ann ].
	self announcer when: APValueRead do: block
]

{ #category : #announcing }
APValueHolder >> whenReadSend: aSelector to: aReceiver [

	self announcer when: APValueRead send: aSelector to: aReceiver
]
